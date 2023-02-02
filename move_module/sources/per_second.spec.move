spec publisher::per_second_v8 {

    spec module {
        // Test function,not needed verify
        pragma verify = true;
        // pragma aborts_if_is_strict;
    }

    spec create_session<CoinType>(requester: &signer, max_duration: u64, second_rate: u64, room_id: string::String) {
        let requester_addr = signer::address_of(requester);
        ensures exists<Session<CoinType>>(requester_addr);
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