spec publisher::per_second_v8 {
    spec module {
        // Test function,not needed verify
        pragma verify = true;
        pragma aborts_if_is_strict;
    }

    spec create_session<CoinType>(requester: &signer, max_duration: u64, second_rate: u64, room_id: string::String) {
        let requester_addr = signer::address_of(requester);

        // Pre-conditions
        requires coin::is_account_registered<CoinType>(requester_addr);

        // Post-conditions
        ensures exists<Session<CoinType>>(requester_addr);

        // Aborts-conditions
        let session = global<Session<CoinType>>(requester_addr);
        let balance = coin::balance<CoinType>(requester_addr);
        let deposit_amount = max_duration * second_rate;

        aborts_if deposit_amount > MAX_U64;
        aborts_if balance < deposit_amount;
        aborts_if timestamp::now_microseconds() > MAX_U64; // for now.now_seconds()
        aborts_if session.create_session_events.counter > MAX_U64;
        aborts_if global<account::Account>(requester_addr).guid_creation_num > MAX_U64;

        // TODO: More aborts conditions
    }

    spec join_session<CoinType>(receiver: &signer, requester_addr: address) {
        pragma verify=false;
    }

    spec start_session<CoinType>(requester: &signer) {
        pragma verify=false;
    }

    spec close_session<CoinType>(account: &signer, requester_addr: address) {
        pragma verify=false;
    }

    spec remaining_time<CoinType>(requester_addr: address): u64 {
        pragma verify=false;
    }

    spec elapsed_time<CoinType>(requester_addr: address): u64 {
        pragma verify=false;
    }
}