/*
PerSecond.live: Timely Paid Aptos Stream
    1. A requester can initiate a payment stream session for a video call
    2. The receiver can join the session through the video call link
    3. Upon joining both parties, the requester can start the session and activate the per-second payment stream
    4. Upon closing of the session, send payment to the receiver, and refund any remaining funds to the requester
*/

module publisher::per_second_v7 {
    use aptos_framework::account;
    use aptos_framework::coin::{Self, Coin};
    use aptos_framework::timestamp;
    use aptos_framework::event::{Self, EventHandle};
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

        create_session_events: EventHandle<CreateSessionEvent>,
        join_session_events: EventHandle<JoinSessionEvent>,
        start_session_events: EventHandle<StartSessionEvent>,
        close_session_events: EventHandle<CloseSessionEvent>,
    }

    struct CreateSessionEvent has drop, store {
        requester: address,
        max_duration: u64,
        second_rate: u64,
        room_id: string::String,
        created_at: u64,
    }

    struct JoinSessionEvent has drop, store {
        requester: address,
        receiver: address,
        joined_at: u64,
    }

    struct StartSessionEvent has drop, store {
        requester: address,
        receiver: address,
        started_at: u64,
    }

    struct CloseSessionEvent has drop, store {
        requester: address,
        receiver: address,
        started_at: u64,
        finished_at: u64,
        paid_amount: u64,
        refunded_amount: u64,
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

                create_session_events: account::new_event_handle<CreateSessionEvent>(requester),
                join_session_events: account::new_event_handle<JoinSessionEvent>(requester),
                start_session_events: account::new_event_handle<StartSessionEvent>(requester),
                close_session_events: account::new_event_handle<CloseSessionEvent>(requester),
            })
        };

        let session = borrow_global_mut<Session<CoinType>>(requester_addr);
        event::emit_event(&mut session.create_session_events, CreateSessionEvent {
            requester: requester_addr, max_duration, second_rate, room_id, created_at: timestamp::now_seconds()
        });
    }

    // 2. The receiver can join the session through the video call link
    public entry fun join_session<CoinType>(receiver: &signer, requester_addr: address) acquires Session {
        let receiver_addr = signer::address_of(receiver);
        let session = borrow_global_mut<Session<CoinType>>(requester_addr);

        assert!(session.receiver == @0x0, error::invalid_state(ERECEIVER_HAS_ALREADY_JOINED));

        session.receiver = receiver_addr;

        event::emit_event(&mut session.join_session_events, JoinSessionEvent {
            requester: requester_addr, receiver: receiver_addr, joined_at: timestamp::now_seconds()
        });
    }

    // 3. Upon joining both parties, the requester can start the session and activate the per-second payment stream
    public entry fun start_session<CoinType>(requester: &signer) acquires Session {
        let requester_addr = signer::address_of(requester);
        let session = borrow_global_mut<Session<CoinType>>(requester_addr);

        assert!(session.receiver != @0x0, error::invalid_state(ERECEIVER_HAS_NOT_JOINED_YET));
        assert!(session.started_at == 0, error::invalid_state(ESESSION_HAS_ALREADY_STARTED));

        session.started_at = timestamp::now_seconds();

        event::emit_event(&mut session.start_session_events, StartSessionEvent {
            requester: requester_addr, receiver: session.receiver, started_at: session.started_at
        });
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

        // send payment to the receiver
        let payment_amount = (session.finished_at - session.started_at) * session.second_rate;
        let coins_for_receiver = coin::extract(&mut all_coins, payment_amount);
        coin::deposit<CoinType>(session.receiver, coins_for_receiver);

        // refund any remaining funds to the requester (coins_for_receiver is extracted out of all_coins)
        let refund_amount = coin::value(&all_coins);
        coin::deposit<CoinType>(requester_addr, all_coins);

        event::emit_event(&mut session.close_session_events, CloseSessionEvent {
            requester: requester_addr,
            receiver: session.receiver,
            started_at: session.started_at,
            finished_at: session.finished_at,
            paid_amount: payment_amount,
            refunded_amount: refund_amount,
        });
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
    public fun get_session_data<CoinType>(requester_addr: address): (u64, u64, u64, u64, string::String, address, u64) acquires Session {
        let session = borrow_global<Session<CoinType>>(requester_addr);

        return (
            session.started_at,
            session.finished_at,
            session.max_duration,
            session.second_rate,
            session.room_id,
            session.receiver,
            coin::value<CoinType>(&session.deposit),
        )
    }
}
