// Payment Stream for 1:n video conference
//   1. A payment stream session can be created by a host
//   2. A session has start & end timestamp (calculated by maxDuration), and secondRate (in APT coin)
//   3. A viewer can join into session in between the start end end time of the session
//   4. When a viewer joins the session, it charges the viewer with the maximum amount:
//      depositAmount = (endAt - currentTime) * secondRate
//   5. When a viewer leave the session or the host close the session, the contract refunds the left over amount to all viewers

module publisher::payment_stream {
    // use aptos_framework::account;
    // use aptos_framework::coin::{Self, Coin};
    // use aptos_framework::aptos_coin::AptosCoin;
    // use aptos_framework::event::{Self, EventHandle};
    use aptos_framework::timestamp;
    use aptos_std::table_with_length::{Self, TableWithLength};
    // use std::error;
    use std::signer;
    // use std::vector;

    struct Host has key, store {
        startAt: u64,
        endAt: u64,
        secondRate: u64, // USDC with 8 decimal points (1e8)
        viewers: TableWithLength<address, Viewer>,
    }

    struct Viewer has key, store {
        joinedAt: u64,
        leftAt: u64,
    }

    public entry fun initialize_session(host: &signer, maxDuration: u64, secondRate: u64) {
        move_to(host, Host {
            startAt: timestamp::now_seconds(),
            endAt: timestamp::now_seconds() + maxDuration,
            secondRate: secondRate,
            viewers: table_with_length::new<address, Viewer>(),
        })
    }

    public entry fun join_session(viewer: &signer, hostAddress: address) acquires Host {
        let viewerAddress = signer::address_of(viewer);
        let host = borrow_global_mut<Host>(hostAddress);

        let currentTime = timestamp::now_seconds();
        table_with_length::add(&mut host.viewers, viewerAddress, Viewer {
            joinedAt: currentTime,
            leftAt: 0,
        });

        // let depositAmount = (host.endAt - currentTime) * host.secondRate;
        // AptosCoin::transfer_from(viewer, hostAddress, depositAmount);
    }

    #[view]
    // Return the total number of viewers in the session
    public fun get_viewers_count(host: &signer): u64 acquires Host {
        let hostAddress = signer::address_of(host);
        let host = borrow_global<Host>(hostAddress);

        table_with_length::length(&host.viewers)
    }

    #[test_only]
    fun setup(aptos_framework: &signer) {
        timestamp::set_time_has_started_for_testing(aptos_framework);
    }

    #[test(aptos_framework = @0x1, host = @0x123, viewer = @0x456)]
    public entry fun test_get_viewers_count(aptos_framework: &signer, host: &signer, viewer: &signer) acquires Host {
        setup(aptos_framework);
        initialize_session(host, 15 * 60, 100);
        assert!(get_viewers_count(host) == 0, 1);

        let hostAddress = signer::address_of(host);
        join_session(viewer, hostAddress);
        assert!(get_viewers_count(host) == 1, 1);
    }
}