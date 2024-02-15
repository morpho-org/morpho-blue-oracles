# Morpho Blue Oracles


Morpho Blue Oracles are contracts that can be used as oracles for markets on [Morpho Blue](https://github.com/morpho-org/morpho-blue).
The oracles implement the `IOracle` interface defined in [`IOracle.sol`](https://github.com/morpho-org/morpho-blue/blob/main/src/interfaces/IOracle.sol#L9): they return the price of 1 asset of collateral token quoted in 1 asset of loan token.

## ChainlinkOracle

The `ChainlinkOracle` is an oracle that uses Chainlink-compliant feeds to provide price data.

This oracle handles the following cases among others (let's say that our pair is A/B):
- A/B is a feed (typically, stETH/ETH).
- B/A is a feed (typically, ETH/USDC).
- A/C and B/C are feeds (typically, stETH/ETH and USDC/ETH).
- A/C, C/D and B/D are feeds (typically, WBTC/BTC, BTC/USD, USDC/USD).
- A/D, and B/C, C/D are feeds (typically, USDC/USD, WBTC/BTC, BTC/USD).
- A/C, C/D and B/E, E/D are feeds.
- A/C and C/B are feeds (typically, WBTC/BTC and BTC/ETH).
- A'/C and B/C are feeds, and there is an exchange rate between A and A'. (typically A=sDAI and A'=DAI).

## Getting Started

Install dependencies: `forge install`

In a `.env` file, set `ETH_RPC_URL` to the URL of an Ethereum provider.

Run test: `forge test`

## Deploy an Oracle

For example, to deploy a `ChainlinkOracle` on the Ethereum mainnet for the sDAI/USDC market, run:

```bash
forge create src/ChainlinkOracle.sol:ChainlinkOracle --constructor-args "0x83F20F44975D03b1b09e64809B757c47f942BEeA" "0xAed0c38402a5d19df6E4c03F4E2DceD6e29c1ee9" "0x0000000000000000000000000000000000000000" "0x8fFfFfd4AfB6115b954Bd326cbe7B4BA576818f6" "0x0000000000000000000000000000000000000000" "1000000000000000000" "18" "6" --rpc-url https://eth-mainnet.g.alchemy.com/v2/<alchemy-key> --from <deployer-address> --ledger
``````

And for the rETH/WETH market, run:

```bash
forge create src/ChainlinkOracle.sol:ChainlinkOracle --constructor-args "0x0000000000000000000000000000000000000000" "0x536218f9E9Eb48863970252233c8F271f554C2d0" "0x0000000000000000000000000000000000000000" "0x0000000000000000000000000000000000000000" "0x0000000000000000000000000000000000000000" "1" "18" "18" --rpc-url https://eth-mainnet.g.alchemy.com/v2/<alchemy-key> --from <deployer-address> --ledger
```

## Audits

All audits are stored in the [audits](./audits/)' folder.

## License

Morpho Blue Oracles are licensed under `GPL-2.0-or-later`, see [`LICENSE`](./LICENSE).