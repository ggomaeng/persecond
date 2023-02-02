/*
Payment stream for 1:1 video consulting
    1. A requester can initiate a payment stream session for a video call
    2. The receiver can join the session through the video call link
    3. Upon joining both parties, the requester can start the session and activate the per-second payment stream
    4. Upon closing of the session, send payment to the receiver, and refund any remaining funds to the requester
*/

module publisher::payment_stream {
    // use aptos_framework::account;
    use aptos_framework::coin::{Self, Coin};
    // use aptos_framework::event::{Self, EventHandle};
    use aptos_framework::timestamp;
    // use std::error;
    use std::signer;
    // use std::vector;

    const ERECEIVER_HAS_ALREADY_JOINED: u64 = 1;
    const ERECEIVER_HAS_NOT_JOINED_YET: u64 = 2;
    const ESESSION_HAS_ALREADY_STARTED: u64 = 3;
    const ESESSION_HAS_ALREADY_FINISHED: u64 = 4;
    const EPERMISSION_DENIED: u64 = 5;

    struct Session<phantom CoinType> has key, store {
        started_at: u64,
        finished_at: u64,
        max_duration: u64,
        second_rate: u64, // price per second
        receiver: address,
        deposit: Coin<CoinType>,
    }

    // 1. A requester can initiate a payment stream session for a video call.
    public entry fun create_session<CoinType>(requester: &signer, max_duration: u64, second_rate: u64) {
        let deposit_amount = max_duration * second_rate;
        let coins = coin::withdraw<CoinType>(requester, deposit_amount);

        move_to(requester, Session {
            started_at: 0,
            finished_at: 0,
            max_duration: max_duration,
            second_rate: second_rate,
            receiver: @0x0, // requester doesn't know the receiver's wallet address yet
            deposit: coins,
        })
    }

    // 2. The receiver can join the session through the video call link
    public entry fun join_session<CoinType>(receiver: &signer, requester_addr: address) acquires Session {
        let receiver_addr = signer::address_of(receiver);
        let session = borrow_global_mut<Session<CoinType>>(requester_addr);

        assert!(session.receiver == @0x0, ERECEIVER_HAS_ALREADY_JOINED);

        session.receiver = receiver_addr;
    }

    // 3. Upon joining both parties, the requester can start the session and activate the per-second payment stream
    public entry fun start_session<CoinType>(requester: &signer) acquires Session {
        let requester_addr = signer::address_of(requester);
        let session = borrow_global_mut<Session<CoinType>>(requester_addr);

        assert!(session.receiver != @0x0, ERECEIVER_HAS_NOT_JOINED_YET);
        assert!(session.started_at == 0, ESESSION_HAS_ALREADY_STARTED);

        session.started_at = timestamp::now_seconds();
    }

    // 4. Upon closing of the session, send payment to the receiver, and refund any remaining funds to the requester
    public entry fun close_session<CoinType>(account: &signer, requester_addr: address) acquires Session {
        let account_addr = signer::address_of(account);
        let session = borrow_global_mut<Session<CoinType>>(requester_addr);

        assert!(session.finished_at == 0, ESESSION_HAS_ALREADY_FINISHED);
        assert!(requester_addr == account_addr || session.receiver == account_addr, EPERMISSION_DENIED);

        let current_time = timestamp::now_seconds();
        let deposit_amount = session.max_duration * session.second_rate;

        // if the session hasn't started yet, refund the full amount to the requester
        if (session.started_at == 0) {
            session.finished_at = current_time;
            let coins_to_refund = coin::withdraw<CoinType>(account, deposit_amount);
            coin::deposit<CoinType>(requester_addr, coins_to_refund);
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
        let coins_for_receiver = coin::withdraw<CoinType>(account, payment_amount);
        coin::deposit<CoinType>(session.receiver, coins_for_receiver);

        // refund any remaining funds to the requester
        let coinst_to_refund = coin::withdraw<CoinType>(account, deposit_amount - payment_amount);
        coin::deposit<CoinType>(requester_addr, coinst_to_refund);
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

    #[test_only]
    use aptos_framework::aptos_account;
    #[test_only]
    use aptos_framework::aptos_coin;
    #[test_only]
    use aptos_framework::aptos_coin::AptosCoin;

    #[test_only]
    fun setup(aptos_framework: &signer) {
        timestamp::set_time_has_started_for_testing(aptos_framework);
    }

    #[test_only]
    fun set_up_account(aptos_framework: &signer, account: &signer, amount: u64) {
        let (burn_cap, mint_cap) = aptos_coin::initialize_for_test(aptos_framework);
        coin::destroy_burn_cap<AptosCoin>(burn_cap);

        let account_addr = signer::address_of(account);
        aptos_account::create_account(account_addr);
        coin::register<AptosCoin>(account);
        let coins = coin::mint<AptosCoin>(amount, &mint_cap);
        coin::deposit<AptosCoin>(account_addr, coins);

        coin::destroy_mint_cap<AptosCoin>(mint_cap); // Should we store this for additional mints?
    }

    #[test(aptos_framework = @0x1, requester = @0x123)]
    public entry fun test_create_session(aptos_framework: &signer, requester: &signer) acquires Session {
        setup(aptos_framework);
        set_up_account(aptos_framework, requester, 10000);

        create_session<AptosCoin>(requester, 3600, 1);

        let requester_addr = signer::address_of(requester);

        assert!(coin::balance<AptosCoin>(requester_addr) == 10000 - 3600, 1);

        // Remaining time
        assert!(remaining_time<AptosCoin>(requester_addr) == 3600, 2);
        timestamp::fast_forward_seconds(1000);
        assert!(remaining_time<AptosCoin>(requester_addr) == 3600, 2); // should not change if not started
    }
}
