#[test_only]
module publisher::payment_stream_test {
    use aptos_framework::aptos_account;
    use aptos_framework::coin;
    use aptos_framework::aptos_coin;
    use aptos_framework::aptos_coin::AptosCoin;
    use aptos_framework::timestamp;
    use std::signer;
    // use std::unit_test;
    // use std::vector;
    use std::string;

    use publisher::per_second;

    fun setup(aptos_framework: &signer) {
        timestamp::set_time_has_started_for_testing(aptos_framework);
        timestamp::fast_forward_seconds(1000); // prevent starting from 0
    }

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
    public fun test_create_session(aptos_framework: &signer, requester: &signer) {
        setup(aptos_framework);
        let requester_addr = set_up_account(aptos_framework, requester, 10000);

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
        let requester_addr = set_up_account(aptos_framework, requester, 10000);

        per_second::create_session<AptosCoin>(requester, 3600, 1, string::utf8(b"room_abc"));
        assert!(coin::balance<AptosCoin>(requester_addr) == 10000 - 3600, 1);

        // Refund the full amount to the requester if the session is closed without starting
        per_second::close_session<AptosCoin>(requester, requester_addr);
        assert!(coin::balance<AptosCoin>(requester_addr) == 10000, 2);
    }

    #[test(aptos_framework = @0x1, requester = @0x123)]
    public fun test_recreate_the_session_after_finish(aptos_framework: &signer, requester: &signer) {
        setup(aptos_framework);
        let requester_addr = set_up_account(aptos_framework, requester, 10000);

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
        set_up_account(aptos_framework, requester, 10000);

        per_second::create_session<AptosCoin>(requester, 3600, 1, string::utf8(b"room_abc"));
        per_second::create_session<AptosCoin>(requester, 1000, 2, string::utf8(b"room_def")); // should fail
    }
}
