# PerSecond Modules
Payment stream module for 1:1 video consulting
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
