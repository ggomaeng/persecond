# PerSecond Modules
Timely Paid Aptos Stream
1. A requester can initiate a payment stream session for a video call
2. The receiver can join the session through the video call link
3. Upon joining both parties, the requester can start the session and activate the per-second payment stream
4. Upon closing of the session, send payment to the receiver, and refund any remaining funds to the requester

## Setup dev environment
```sh
brew install aptos
aptos init
```

## Run tests
```sh
aptos move test
```

## Deploy
```sh
aptos move publish --named-addresses publisher=default
```
```json
{
  "Result": {
    "transaction_hash": "0x48f5805dd66fd12f8fc25b901f910e8df57bc3ad8c406d1d2697417d48b1ba5f",
    "gas_used": 16776,
    "gas_unit_price": 100,
    "sender": "e53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c",
    "sequence_number": 16,
    "success": true,
    "timestamp_us": 1675362570004417,
    "version": 9364062,
    "vm_status": "Executed successfully"
  }
}
```
