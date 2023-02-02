spec publisher::per_second_v8 {
    use aptos_framework::chain_status;

    spec module {
        pragma verify = true;
        // pragma aborts_if_is_strict;
    }

    spec create_session<CoinType>(requester: &signer, max_duration: u64, second_rate: u64, room_id: string::String) {
        let requester_addr = signer::address_of(requester);
        ensures exists<Session<CoinType>>(requester_addr);

        // aborts_if !exists<account::Account>(requester_addr);
        // aborts_if max_duration * second_rate > MAX_U64;
    }

    spec join_session<CoinType>(receiver: &signer, requester_addr: address) {
        // TODO: missing aborts_if spec
        pragma verify=false;

        // aborts_if !exists<Session<CoinType>>(requester_addr);
        // aborts_if global<Session<CoinType>>(requester_addr).receiver != @0x0;
    }

    spec start_session<CoinType>(requester: &signer) {
        // TODO: missing aborts_if spec
        pragma verify=false;
    }

    spec close_session<CoinType>(account: &signer, requester_addr: address) {
        // TODO: missing aborts_if spec
        pragma verify=false;

        requires chain_status::is_operating(); // Ensures existence of Timestamp

        // let addr = signer::address_of(account);
        // let session = global<Session<CoinType>>(requester_addr);

        // aborts_if !exists<Session<CoinType>>(requester_addr);
        // aborts_if session.finished_at != 0;
        // aborts_if addr != requester_addr && addr != session.receiver;
    }

    spec remaining_time<CoinType>(requester_addr: address): u64 {
        // TODO: missing aborts_if spec
        pragma verify=false;
    }

    spec elapsed_time<CoinType>(requester_addr: address): u64 {
        // TODO: missing aborts_if spec
        pragma verify=false;
    }
}