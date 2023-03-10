#[test_only]
module publisher::payment_stream_tests {
    use aptos_framework::aptos_account;
    use aptos_framework::coin;
    use aptos_framework::aptos_coin::{Self, AptosCoin};
    use aptos_framework::timestamp;
    use std::signer;
    use std::string;

    use publisher::per_second_v8 as per_second;

    fun setup(aptos_framework: &signer) {
        timestamp::set_time_has_started_for_testing(aptos_framework);
        timestamp::fast_forward_seconds(1000); // prevent starting from 0
    }

    fun setup_and_mint(aptos_framework: &signer, account: &signer, amount: u64): address {
        let (burn_cap, mint_cap) = aptos_coin::initialize_for_test(aptos_framework);
        coin::destroy_burn_cap<AptosCoin>(burn_cap);

       let account_addr = setup_account_and_register_apt(account);

        let coins = coin::mint<AptosCoin>(amount, &mint_cap);
        coin::deposit<AptosCoin>(account_addr, coins);

        coin::destroy_mint_cap<AptosCoin>(mint_cap); // cannot mint APT anymore

        signer::address_of(account)
    }

    fun setup_account_and_register_apt(account: &signer): address {
        let account_addr = signer::address_of(account);
        aptos_account::create_account(account_addr);
        coin::register<AptosCoin>(account);

        signer::address_of(account)
    }

    #[test(aptos_framework = @0x1, requester = @0x123)]
    public fun test_create_session(aptos_framework: &signer, requester: &signer) {
        setup(aptos_framework);
        let requester_addr = setup_and_mint(aptos_framework, requester, 10000);

        per_second::create_session<AptosCoin>(requester, 3600, 1, string::utf8(b"room_abc"));

        // Should deduct the deposit amount from the requester's balance
        assert!(coin::balance<AptosCoin>(requester_addr) == 10000 - 3600, 1);

        // Remaining time
        assert!(per_second::remaining_time<AptosCoin>(requester_addr) == 3600, 2);
        timestamp::fast_forward_seconds(1000);
        assert!(per_second::remaining_time<AptosCoin>(requester_addr) == 3600, 2); // should not change if not started

        // Elapsed time
        assert!(per_second::elapsed_time<AptosCoin>(requester_addr) == 0, 3); // should not chage if not started
    }

    #[test(aptos_framework = @0x1, requester = @0x123)]
    public fun test_full_refund_when_not_started(aptos_framework: &signer, requester: &signer) {
        setup(aptos_framework);
        let requester_addr = setup_and_mint(aptos_framework, requester, 10000);

        per_second::create_session<AptosCoin>(requester, 3600, 1, string::utf8(b"room_abc"));
        assert!(coin::balance<AptosCoin>(requester_addr) == 10000 - 3600, 1);

        // Refund the full amount to the requester if the session is closed without starting
        per_second::close_session<AptosCoin>(requester, requester_addr);
        assert!(coin::balance<AptosCoin>(requester_addr) == 10000, 2);
    }

    #[test(aptos_framework = @0x1, requester = @0x123)]
    public fun test_recreate_the_session_after_finish(aptos_framework: &signer, requester: &signer) {
        setup(aptos_framework);
        let requester_addr = setup_and_mint(aptos_framework, requester, 10000);

        per_second::create_session<AptosCoin>(requester, 3600, 1, string::utf8(b"room_abc"));
        per_second::close_session<AptosCoin>(requester, requester_addr); // full refund

        assert!(coin::balance<AptosCoin>(requester_addr) == 10000, 1);
        // Should be able to create a new session again
        per_second::create_session<AptosCoin>(requester, 1000, 2, string::utf8(b"room_def"));
        assert!(coin::balance<AptosCoin>(requester_addr) == 10000 - 2000, 2);
    }

    #[test(aptos_framework = @0x1, requester = @0x123)]
    #[expected_failure(abort_code = 0x30001, location = per_second)]
    public fun test_recreate_the_session_before_finish(aptos_framework: &signer, requester: &signer) {
        setup(aptos_framework);
        setup_and_mint(aptos_framework, requester, 10000);

        per_second::create_session<AptosCoin>(requester, 3600, 1, string::utf8(b"room_abc"));
        per_second::create_session<AptosCoin>(requester, 1000, 2, string::utf8(b"room_def")); // should fail
    }

    #[test(aptos_framework = @0x1, requester = @0x123, receiver = @0x456)]
    public fun test_join_session(aptos_framework: &signer, requester: &signer, receiver: &signer) {
        setup(aptos_framework);
        let requester_addr = setup_and_mint(aptos_framework, requester, 10000);
        let receiver_addr = setup_account_and_register_apt(receiver);

        per_second::create_session<AptosCoin>(requester, 3600, 2, string::utf8(b"room_abc"));
        per_second::join_session<AptosCoin>(receiver, requester_addr);
        assert!(coin::balance<AptosCoin>(receiver_addr) == 0, 1); // didn't get paid yet

        // Verify the session data
        let (started_at, finished_at, max_duration, second_rate, room_id, receiver_addr_2, deposit_amount) =
            per_second::get_session_data<AptosCoin>(requester_addr);

        assert!(started_at == 0, 1);
        assert!(finished_at == 0, 1);
        assert!(max_duration == 3600, 1);
        assert!(second_rate == 2, 1);
        assert!(room_id == string::utf8(b"room_abc"), 1);
        assert!(receiver_addr_2 == receiver_addr, 1);
        assert!(deposit_amount == 7200, 1);
    }

    #[test(aptos_framework = @0x1, requester = @0x123, receiver = @0x456)]
    public fun test_start_session(aptos_framework: &signer, requester: &signer, receiver: &signer) {
        setup(aptos_framework);
        let requester_addr = setup_and_mint(aptos_framework, requester, 10000);
        setup_account_and_register_apt(receiver);

        per_second::create_session<AptosCoin>(requester, 3600, 2, string::utf8(b"room_abc"));
        per_second::join_session<AptosCoin>(receiver, requester_addr);

        timestamp::fast_forward_seconds(4000); // 1000 + 4000 = 5000

        // Start the session
        per_second::start_session<AptosCoin>(requester);
        assert!(coin::balance<AptosCoin>(requester_addr) == 10000 - 7200, 1); // should deduct the deposit amount

        // Verify the session data
        let (started_at, _, max_duration, _, _, _, _) = per_second::get_session_data<AptosCoin>(requester_addr);

        assert!(started_at == 5000, 2);

        // Check initial timestamps
        assert!(per_second::elapsed_time<AptosCoin>(requester_addr) == 0, 3);
        assert!(per_second::remaining_time<AptosCoin>(requester_addr) == max_duration, 3);

        // Check status after 30 minutes
        timestamp::fast_forward_seconds(1800);
        assert!(per_second::elapsed_time<AptosCoin>(requester_addr) == 1800, 3);
        assert!(per_second::remaining_time<AptosCoin>(requester_addr) == max_duration - 1800, 3);
    }

    #[test(aptos_framework = @0x1, requester = @0x123, receiver = @0x456)]
    public fun test_close_session(aptos_framework: &signer, requester: &signer, receiver: &signer) {
        setup(aptos_framework);
        let requester_addr = setup_and_mint(aptos_framework, requester, 10000);
        let receiver_addr = setup_account_and_register_apt(receiver);

        per_second::create_session<AptosCoin>(requester, 1800, 3, string::utf8(b"room_abc"));
        per_second::join_session<AptosCoin>(receiver, requester_addr);
        per_second::start_session<AptosCoin>(requester);
        assert!(coin::balance<AptosCoin>(requester_addr) == 10000 - 1800 * 3, 1); // should deduct the deposit amount

        // Finish the session in the middle (15 minutes elapsed)
        timestamp::fast_forward_seconds(900);
        per_second::close_session<AptosCoin>(receiver, requester_addr); // both requester and receiver can call this

        // Verify the session data
        let (started_at, finished_at, max_duration, second_rate, room_id, receiver_addr_2, deposit_amount) =
            per_second::get_session_data<AptosCoin>(requester_addr);

        assert!(started_at == 1000, 2);
        assert!(finished_at == 1900, 2);
        assert!(max_duration == 1800, 2); // should not be changed
        assert!(second_rate == 3, 2); // should not be changed
        assert!(room_id == string::utf8(b"room_abc"), 2); // should not be changed
        assert!(receiver_addr_2 == receiver_addr, 2); // should not be changed
        assert!(deposit_amount == 0, 2); // should be cleared

        // The requester should be refunded half of the total amount
        assert!(coin::balance<AptosCoin>(requester_addr) == 10000 - 900 * 3, 3);
        // The receiver should receive half of the total amount
        assert!(coin::balance<AptosCoin>(receiver_addr) == 900 * 3, 3);
    }
}
