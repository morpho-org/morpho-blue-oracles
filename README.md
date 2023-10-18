# Morpho Blue Oracles

[Morpho Blue](https://github.com/morpho-org/morpho-blue) is a trustless lending primitive that offers unparalleled efficiency and flexibility.

Morpho Blue Oracles are contracts that can be used as oracles for markets on Morpho Blue.
The oracles must implement the `IOracle` interface defined in [`IOracle.sol`](https://github.com/morpho-org/morpho-blue/blob/main/src/interfaces/IOracle.sol#L9).

## ChainlinkOracle

The `ChainlinkOracle` is an oracle that uses Chainlink-compliant feeds to provide price data.

This Oracle handles the following cases among others (let's say that our pair is A/B):
- A/B is a feed (typically, stETH/ETH).
- B/A is a feed (typically, USDC/ETH).
- A/C and B/C are feeds (typically, stETH/ETH and USDC/ETH).
- A/C, C/D and B/D are feeds (typically, WBTC/BTC, BTC/USD, USDC/USD).
- A/D, and B/C, C/D are feeds (typically, USDC/USD, WBTC/BTC, BTC/USD).
- A/C, C/D and B/E, E/D are feeds.
- A/C and C/B are feeds (typically, WBTC/BTC and BTC/ETH).
- A'/C and B/C are feeds, and there is an exchange rate between A and A'. (typically A=sDAI and A'=DAI).

## Getting Started

Install dependencies: `forge install`

Run test: `forge test`

## License

Morpho Blue Oracles are licensed under `GPL-2.0-or-later`, see [`LICENSE`](./LICENSE).