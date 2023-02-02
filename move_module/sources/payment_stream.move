/*
Payment stream for 1:1 video consulting
    1. A requester can initiate a payment stream session for a video call
    2. The receiver can join the session through the video call link
    3. Upon joining both parties, the requester can start the session and activate the per-second payment stream
    4. Upon closing of the session, send payment to the receiver, and refund any remaining funds to the requester
*/

module publisher::payment_stream_v3 {
    use aptos_framework::coin::{Self, Coin};
    use aptos_framework::timestamp;
    use std::error;
    use std::signer;
    use std::string;

    const EALREADY_HAS_OPEN_SESSION: u64 = 1;
    const ERECEIVER_HAS_ALREADY_JOINED: u64 = 2;
    const ERECEIVER_HAS_NOT_JOINED_YET: u64 = 3;
    const ESESSION_HAS_ALREADY_STARTED: u64 = 4;
    const ESESSION_HAS_ALREADY_FINISHED: u64 = 5;
    const EPERMISSION_DENIED: u64 = 6;

    struct Session<phantom CoinType> has key, store {
        started_at: u64,
        finished_at: u64,
        max_duration: u64,
        second_rate: u64, // price per second
        room_id: string::String,
        receiver: address,
        deposit: Coin<CoinType>,
    }

    // 1. A requester can initiate a payment stream session for a video call.
    public entry fun create_session<CoinType>(requester: &signer, max_duration: u64, second_rate: u64, room_id: string::String) acquires Session {
        let requester_addr = signer::address_of(requester);
        let deposit_amount = max_duration * second_rate;

        if (exists<Session<CoinType>>(requester_addr)) {
            let session = borrow_global_mut<Session<CoinType>>(requester_addr);
            assert!(session.finished_at > 0, error::invalid_state(EALREADY_HAS_OPEN_SESSION));

            // Overwrite the finished session
            session.started_at = 0;
            session.finished_at = 0;
            session.max_duration = max_duration;
            session.second_rate = second_rate;
            session.room_id = room_id;
            session.receiver = @0x0;
            coin::merge(&mut session.deposit, coin::withdraw<CoinType>(requester, deposit_amount));
        } else {
            move_to(requester, Session {
                started_at: 0,
                finished_at: 0,
                max_duration: max_duration,
                second_rate: second_rate,
                room_id: room_id,
                receiver: @0x0, // requester doesn't know the receiver's wallet address yet
                deposit: coin::withdraw<CoinType>(requester, deposit_amount),
            })
        }
    }

    // 2. The receiver can join the session through the video call link
    public entry fun join_session<CoinType>(receiver: &signer, requester_addr: address) acquires Session {
        let receiver_addr = signer::address_of(receiver);
        let session = borrow_global_mut<Session<CoinType>>(requester_addr);

        assert!(session.receiver == @0x0, error::invalid_state(ERECEIVER_HAS_ALREADY_JOINED));

        session.receiver = receiver_addr;
    }

    // 3. Upon joining both parties, the requester can start the session and activate the per-second payment stream
    public entry fun start_session<CoinType>(requester: &signer) acquires Session {
        let requester_addr = signer::address_of(requester);
        let session = borrow_global_mut<Session<CoinType>>(requester_addr);

        assert!(session.receiver != @0x0, error::invalid_state(ERECEIVER_HAS_NOT_JOINED_YET));
        assert!(session.started_at == 0, error::invalid_state(ESESSION_HAS_ALREADY_STARTED));

        session.started_at = timestamp::now_seconds();
    }

    // 4. Upon closing of the session, send payment to the receiver, and refund any remaining funds to the requester
    public entry fun close_session<CoinType>(account: &signer, requester_addr: address) acquires Session {
        let account_addr = signer::address_of(account);
        let session = borrow_global_mut<Session<CoinType>>(requester_addr);

        assert!(session.finished_at == 0, error::invalid_state(ESESSION_HAS_ALREADY_FINISHED));
        assert!(account_addr == requester_addr || account_addr == session.receiver, error::permission_denied(EPERMISSION_DENIED));

        let current_time = timestamp::now_seconds();

        // get all deposited coins
        let all_coins = coin::extract_all(&mut session.deposit);

        // if the session hasn't started yet, refund the full amount to the requester
        if (session.started_at == 0) {
            session.finished_at = current_time;
            coin::deposit<CoinType>(requester_addr, all_coins);
            return
        };

        let finished_at_max = session.started_at + session.max_duration;
        session.finished_at = if (finished_at_max > current_time) {
            current_time
        } else {
            finished_at_max
        };

        let payment_amount = (session.finished_at - session.started_at) * session.second_rate;

        // send payment to the receiver
        let coins_for_receiver = coin::extract(&mut all_coins, payment_amount);
        coin::deposit<CoinType>(session.receiver, coins_for_receiver);

        // refund any remaining funds to the requester (coins_for_receiver is extracted out of all_coins)
        coin::deposit<CoinType>(requester_addr, all_coins);
    }

    #[view]
    public fun remaining_time<CoinType>(requester_addr: address): u64 acquires Session {
        let session = borrow_global<Session<CoinType>>(requester_addr);
        let current_time = timestamp::now_seconds();

        if (session.started_at == 0) {
            return session.max_duration
        };

        let finished_at_max = session.started_at + session.max_duration;
        if (finished_at_max > current_time) {
            return finished_at_max - current_time
        } else {
            return 0
        }
    }

    #[view]
    public fun elapsed_time<CoinType>(requester_addr: address): u64 acquires Session {
        let session = borrow_global<Session<CoinType>>(requester_addr);
        let current_time = timestamp::now_seconds();

        if (session.started_at == 0) {
            return 0
        };

        let finished_at_max = session.started_at + session.max_duration;
        if (finished_at_max > current_time) {
            return current_time - session.started_at
        } else {
            return session.max_duration
        }
    }

    #[test_only]
    use aptos_framework::aptos_account;
    #[test_only]
    use aptos_framework::aptos_coin;
    #[test_only]
    use aptos_framework::aptos_coin::AptosCoin;

    #[test_only]
    fun setup(aptos_framework: &signer) {
        timestamp::set_time_has_started_for_testing(aptos_framework);
        timestamp::fast_forward_seconds(1000); // prevent starting from 0
    }

    #[test_only]
    fun set_up_account(aptos_framework: &signer, account: &signer, amount: u64): address {
        let (burn_cap, mint_cap) = aptos_coin::initialize_for_test(aptos_framework);
        coin::destroy_burn_cap<AptosCoin>(burn_cap);

        let account_addr = signer::address_of(account);
        aptos_account::create_account(account_addr);
        coin::register<AptosCoin>(account);
        let coins = coin::mint<AptosCoin>(amount, &mint_cap);
        coin::deposit<AptosCoin>(account_addr, coins);

        coin::destroy_mint_cap<AptosCoin>(mint_cap); // Should we store this for additional mints?

        signer::address_of(account)
    }

    #[test(aptos_framework = @0x1, requester = @0x123)]
    public fun test_create_session(aptos_framework: &signer, requester: &signer) acquires Session {
        setup(aptos_framework);
        let requester_addr = set_up_account(aptos_framework, requester, 10000);

        create_session<AptosCoin>(requester, 3600, 1, string::utf8(b"room_abc"));

        // Should deduct the deposit amount from the requester's balance
        assert!(coin::balance<AptosCoin>(requester_addr) == 10000 - 3600, 1);

        // Remaining time
        assert!(remaining_time<AptosCoin>(requester_addr) == 3600, 2);
        timestamp::fast_forward_seconds(1000);
        assert!(remaining_time<AptosCoin>(requester_addr) == 3600, 2); // should not change if not started

        // Elapsed time
        assert!(elapsed_time<AptosCoin>(requester_addr) == 0, 3); // should not chage if not started
    }

    #[test(aptos_framework = @0x1, requester = @0x123)]
    public fun test_full_refund_when_not_started(aptos_framework: &signer, requester: &signer) acquires Session {
        setup(aptos_framework);
        let requester_addr = set_up_account(aptos_framework, requester, 10000);

        create_session<AptosCoin>(requester, 3600, 1, string::utf8(b"room_abc"));
        assert!(coin::balance<AptosCoin>(requester_addr) == 10000 - 3600, 1);

        // Refund the full amount to the requester if the session is closed without starting
        close_session<AptosCoin>(requester, requester_addr);
        assert!(coin::balance<AptosCoin>(requester_addr) == 10000, 2);
    }

    #[test(aptos_framework = @0x1, requester = @0x123)]
    public fun test_recreate_the_session_after_finish(aptos_framework: &signer, requester: &signer) acquires Session {
        setup(aptos_framework);
        let requester_addr = set_up_account(aptos_framework, requester, 10000);

        create_session<AptosCoin>(requester, 3600, 1, string::utf8(b"room_abc"));
        close_session<AptosCoin>(requester, requester_addr); // full refund

        assert!(coin::balance<AptosCoin>(requester_addr) == 10000, 1);
        // Should be able to create a new session again
        create_session<AptosCoin>(requester, 1000, 2, string::utf8(b"room_def"));
        assert!(coin::balance<AptosCoin>(requester_addr) == 10000 - 2000, 2);
    }

    #[test(aptos_framework = @0x1, requester = @0x123)]
    #[expected_failure(abort_code = 0x30001, location = Self)]
    public fun test_recreate_the_session_before_finish(aptos_framework: &signer, requester: &signer) acquires Session {
        setup(aptos_framework);
        set_up_account(aptos_framework, requester, 10000);

        create_session<AptosCoin>(requester, 3600, 1, string::utf8(b"room_abc"));
        create_session<AptosCoin>(requester, 1000, 2, string::utf8(b"room_def")); // should fail
    }
}
