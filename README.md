Command to deploy
$ forge create --rpc-url https://scroll-testnet-public.unifra.io --etherscan-api-key <api-key> --private-key <private-key> --verify Lending --legacy
K793M3EGCJDDHCR6Y7TVVQJSIR5GUC57KD

lending: 0x57428157101b85338618f1251bc351a49cd23897
erc20;: 0x2a6811ee59b4a6fb2ef43c15502fa3ee638af274

forge verify-contract 0x2a6811ee59b4a6fb2ef43c15502fa3ee638af274 MyToken\
 --verifier-url $VERIFIER_URL \
 --etherscan-api-key $ETHERSCAN_API_KEY \
 --constructor-args $(cast abi-encode "constructor(string,string)" "MyToken","MTK)

## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

- **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
- **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
- **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
- **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```
