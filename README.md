# Morpho Blue Oracles

Morpho Blue Oracles are contracts that can be used as oracles for markets on [Morpho Blue](https://github.com/morpho-org/morpho-blue).
The oracles implement the `IOracle` interface defined in [`IOracle.sol`](https://github.com/morpho-org/morpho-blue/blob/main/src/interfaces/IOracle.sol#L9): they return the price of 1 asset of collateral token quoted in 1 asset of loan token.

## MorphoChainlinkOracleV2

The `MorphoChainlinkOracleV2` is an oracle that uses Chainlink-interface-compliant feeds to provide price data.

This oracle handles the following cases among others (let's say that our pair is A/B):

- A/B is a feed (typically, stETH/ETH).
- B/A is a feed (typically, ETH/USDC).
- A/C and B/C are feeds (typically, stETH/ETH and USDC/ETH).
- A/C, C/D and B/D are feeds (typically, WBTC/BTC, BTC/USD, USDC/USD).
- A/D, and B/C, C/D are feeds (typically, USDC/USD, WBTC/BTC, BTC/USD).
- A/C, C/D and B/E, E/D are feeds.
- A/C and C/B are feeds (typically, WBTC/BTC and BTC/ETH).
- A'/C and B/C are feeds, and there is an exchange rate between A and A'. (typically A=sDAI and A'=DAI).

## Deploy an Oracle

To deploy a `MorphoChainlinkOracleV2` on Ethereum, it is highly recommended to use the factory `MorphoChainlinkOracleV2Factory`.
To do so, call the `createMorphoChainlinkOracleV2` function with the following parameters:

- `baseVault`: The ERC4626 token vault for the base asset.
- `baseVaultConversionSample`: A sample amount for converting base vault units.
- `baseFeed1`, `baseFeed2`: Chainlink-interface-compliant data feeds for the base asset.
- `baseTokenDecimals`: Decimal precision of the base asset.
- `quoteVault`: The ERC4626 token vault for the quote asset.
- `quoteVaultConversionSample`: A sample amount for converting quote vault units.
- `quoteFeed1`, `quoteFeed2`: Chainlink-interface-compliant data feeds for the quote asset.
- `quoteTokenDecimals`: Decimal precision of the quote asset.
- `salt`: A unique identifier to create deterministic addresses for deployed oracles.

**Warning:** If there is an ERC4626-compliant vault for `baseVault` or `quoteVault`, the `baseTokenDecimals` or `quoteTokenDecimals` are still the decimals of the underlying asset of the vault, and not the decimals of the Vault itself.
E.g: for a MetaMorpho WETH vault, as `baseVault`, the `baseTokenDecimals` is 18 as WETH has 18 decimals.

### Addresses

The address on Ethereum of this factory is [0x3A7bB36Ee3f3eE32A60e9f2b33c1e5f2E83ad766](https://etherscan.io/address/0x3a7bb36ee3f3ee32a60e9f2b33c1e5f2e83ad766#code).

### Examples

Below are the arguments to fill for the creation of the WETH/USDT oracle:

```json
"baseVault": "0x0000000000000000000000000000000000000000",
"baseVaultConversionSample": 1,
"baseFeed1": "0x0000000000000000000000000000000000000000",
"baseFeed2": "0x0000000000000000000000000000000000000000",
"baseTokenDecimals": 18,
"quoteVault":"0x0000000000000000000000000000000000000000",
"quoteVaultConversionSample": 1,
"quoteFeed1": "0xEe9F2375b4bdF6387aa8265dD4FB8F16512A1d46",
"quoteFeed2": "0x0000000000000000000000000000000000000000",
"quoteTokenDecimals": 6,
"salt": "<user-defined value used to make the address unique>",
```

and for the sDAI/USDC oracle:

```json
"baseVault": "0x83F20F44975D03b1b09e64809B757c47f942BEeA",
"baseVaultConversionSample": 1000000000000000000,
"baseFeed1": "0xAed0c38402a5d19df6E4c03F4E2DceD6e29c1ee9",
"baseFeed2": "0x0000000000000000000000000000000000000000",
"baseTokenDecimals": 18,
"quoteVault": "0x0000000000000000000000000000000000000000",
"quoteVaultConversionSample": 1,
"quoteFeed1": "0x8fFfFfd4AfB6115b954Bd326cbe7B4BA576818f6",
"quoteFeed2": "0x0000000000000000000000000000000000000000",
"quoteTokenDecimals": 6,
"salt": "<user-defined value used to make the address unique>",
```

and for the wstETH/ETH oracle:

```json
"baseVault": "0x0000000000000000000000000000000000000000",
"baseVaultConversionSample": 1,
"baseFeed1": "0x905b7dAbCD3Ce6B792D874e303D336424Cdb1421",
"baseFeed2": "0x86392dC19c0b719886221c78AB11eb8Cf5c52812",
"baseTokenDecimals": 18,
"quoteVault": "0x0000000000000000000000000000000000000000",
"quoteVaultConversionSample": 1,
"quoteFeed1": "0x0000000000000000000000000000000000000000",
"quoteFeed2": "0x0000000000000000000000000000000000000000",
"quoteTokenDecimals": 18,
"salt": "<user-defined value used to make the address unique>",
```

## WstETH/stETH Exchange Rate Adapter

A specific implementation, the `WstEthStEthExchangeRateChainlinkAdapter`, provides the exchange rate between wstETH and stETH as a Chainlink-interface-compliant feed.

This adapter is deployed on the Ethereum Mainnet at the address [0x905b7dAbCD3Ce6B792D874e303D336424Cdb1421](https://etherscan.io/address/0x905b7dabcd3ce6b792d874e303d336424cdb1421#code).

## Developers

> [!NOTE]
> `MorphoChainlinkOracleV2Factory` has been deployed on Ethereum and Base with the [metadata hash](https://docs.soliditylang.org/en/latest/metadata.html) included, which appear at two places in the bytecode as it is a factory.

Install dependencies: `forge install`

Run test: `forge test`

## Audits

All audits are stored in the [audits](./audits/)' folder.

## License

Morpho Blue Oracles are licensed under `GPL-2.0-or-later`, see [`LICENSE`](./LICENSE).
