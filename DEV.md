## Running the network

1. Compile the validator:

```bash
cargo b --release
```

2. Setup validator and run faucet:

```bash
./start
```

3. Run validator:

```bash
./bootstrap
```

If you have an error like
```Failed to start validator: "shred version mismatch: expected 50300 found: 24866"```,
you need to go to open the script and change `--expected-shred-version` parameter to the correct value (`24866` in this
case).

4. Deploy programs

```bash
./deploy_programs
```

## Send packet bundles

Bundles can only be accepted via the Block Engine endpoint. The easiest way to do it is to use
the (https://github.com/jito-labs/block_engine_simple)[block engine example] repo.

## Endpoints

- RPC: `http://35.241.172.68:8899`
- Faucet: `http://35.241.172.68:9900`
- Gossip: `http://35.241.172.68:8001`
- WS: `ws://35.241.172.68:8900`
- Block engine: `http://35.241.172.68:1005`
- Block engine auth service: `http://35.241.172.68:1003`
