// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "./Helpers/BaseTest.sol";

import "../lib/forge-std/src/Test.sol";
import "../src/ChainlinkOracle.sol";
import "../src/libraries/ErrorsLib.sol";
import "./mocks/ChainlinkAggregatorMock.sol";

contract ChainlinkOracleTest is BaseTest {
    function testOracleWbtcUsdc() public {
        ChainlinkOracle oracle = new ChainlinkOracle(vaultZero, wBtcBtcFeed, btcUsdFeed, usdcUsdFeed, feedZero, 1, 8, 6);
        (, int256 firstBaseAnswer,,,) = wBtcBtcFeed.latestRoundData();
        (, int256 secondBaseAnswer,,,) = btcUsdFeed.latestRoundData();
        (, int256 quoteAnswer,,,) = usdcUsdFeed.latestRoundData();
        assertEq(
            oracle.price(),
            (uint256(firstBaseAnswer) * uint256(secondBaseAnswer) * 10 ** (36 + 8 + 6 - 8 - 8 - 8))
                / uint256(quoteAnswer)
        );
    }

    function testOracleUsdcWbtc() public {
        ChainlinkOracle oracle = new ChainlinkOracle(vaultZero, usdcUsdFeed, feedZero, wBtcBtcFeed, btcUsdFeed, 1, 6, 8);
        (, int256 baseAnswer,,,) = usdcUsdFeed.latestRoundData();
        (, int256 firstQuoteAnswer,,,) = wBtcBtcFeed.latestRoundData();
        (, int256 secondQuoteAnswer,,,) = btcUsdFeed.latestRoundData();
        assertEq(
            oracle.price(),
            (uint256(baseAnswer) * 10 ** (36 + 8 + 8 + 8 - 6 - 8))
                / (uint256(firstQuoteAnswer) * uint256(secondQuoteAnswer))
        );
    }

    function testOracleWbtcEth() public {
        ChainlinkOracle oracle = new ChainlinkOracle(vaultZero, wBtcBtcFeed, btcEthFeed, feedZero, feedZero, 1, 8, 18);
        (, int256 firstBaseAnswer,,,) = wBtcBtcFeed.latestRoundData();
        (, int256 secondBaseAnswer,,,) = btcEthFeed.latestRoundData();
        assertEq(oracle.price(), (uint256(firstBaseAnswer) * uint256(secondBaseAnswer) * 10 ** (36 + 18 - 8 - 8 - 18)));
    }

    function testOracleStEthUsdc() public {
        ChainlinkOracle oracle = new ChainlinkOracle(vaultZero, stEthEthFeed, feedZero, usdcEthFeed, feedZero, 1, 18, 6);
        (, int256 baseAnswer,,,) = stEthEthFeed.latestRoundData();
        (, int256 quoteAnswer,,,) = usdcEthFeed.latestRoundData();
        assertEq(oracle.price(), uint256(baseAnswer) * 10 ** (36 + 18 + 6 - 18 - 18) / uint256(quoteAnswer));
    }

    function testOracleEthUsd() public {
        ChainlinkOracle oracle = new ChainlinkOracle(vaultZero, ethUsdFeed, feedZero, feedZero, feedZero, 1, 18, 0);
        (, int256 expectedPrice,,,) = ethUsdFeed.latestRoundData();
        assertEq(oracle.price(), uint256(expectedPrice) * 10 ** (36 - 18 - 8));
    }

    function testOracleStEthEth() public {
        ChainlinkOracle oracle = new ChainlinkOracle(vaultZero, stEthEthFeed, feedZero, feedZero, feedZero, 1, 18, 18);
        (, int256 expectedPrice,,,) = stEthEthFeed.latestRoundData();
        assertEq(oracle.price(), uint256(expectedPrice) * 10 ** (36 + 18 - 18 - 18));
        assertApproxEqRel(oracle.price(), 1e36, 0.01 ether);
    }

    function testOracleEthStEth() public {
        ChainlinkOracle oracle = new ChainlinkOracle(vaultZero, feedZero, feedZero, stEthEthFeed, feedZero, 1, 18, 18);
        (, int256 expectedPrice,,,) = stEthEthFeed.latestRoundData();
        assertEq(oracle.price(), 10 ** (36 + 18 + 18 - 18) / uint256(expectedPrice));
        assertApproxEqRel(oracle.price(), 1e36, 0.01 ether);
    }

    function testOracleUsdcUsd() public {
        ChainlinkOracle oracle = new ChainlinkOracle(vaultZero, usdcUsdFeed, feedZero, feedZero, feedZero, 1, 6, 0);
        assertApproxEqRel(oracle.price(), 1e36 / 1e6, 0.01 ether);
    }

    function testNegativeAnswer(int256 price) public {
        price = bound(price, type(int256).min, -1);
        ChainlinkAggregatorMock aggregator = new ChainlinkAggregatorMock();
        ChainlinkOracle oracle = new ChainlinkOracle(
            vaultZero, AggregatorV3Interface(address(aggregator)), feedZero, feedZero, feedZero, 1, 18, 0
        );
        aggregator.setAnwser(price);
        vm.expectRevert(bytes(ErrorsLib.NEGATIVE_ANSWER));
        oracle.price();
    }

    function testSDaiEthOracle() public {
        ChainlinkOracle oracle =
            new ChainlinkOracle(sDaiVault, daiEthFeed, feedZero, feedZero, feedZero, 10 ** 18, 18, 18);
        (, int256 expectedPrice,,,) = daiEthFeed.latestRoundData();
        assertEq(
            oracle.price(),
            sDaiVault.convertToAssets(1e18) * uint256(expectedPrice) * 10 ** (36 + 18 + 0 - 18 - 18 - 18)
        );
    }

    function testSDaiUsdcOracle() public {
        ChainlinkOracle oracle =
            new ChainlinkOracle(sDaiVault, daiEthFeed, feedZero, usdcEthFeed, feedZero, 10 ** 18, 18, 6);
        (, int256 baseAnswer,,,) = daiEthFeed.latestRoundData();
        (, int256 quoteAnswer,,,) = usdcEthFeed.latestRoundData();
        assertEq(
            oracle.price(),
            sDaiVault.convertToAssets(1e18) * uint256(baseAnswer) * 10 ** (36 + 6 + 18 - 18 - 18 - 18)
                / uint256(quoteAnswer)
        );
        // DAI has 12 more decimals than USDC.
        uint256 expectedPrice = 10 ** (36 - 12);
        // Admit a 50% interest gain before breaking this test.
        uint256 deviation = 0.5 ether;
        assertApproxEqRel(oracle.price(), expectedPrice, deviation);
    }

    function testConstructorZeroVaultConversionSample() public {
        vm.expectRevert(bytes(ErrorsLib.VAULT_CONVERSION_SAMPLE_IS_ZERO));
        new ChainlinkOracle(sDaiVault, daiEthFeed, feedZero, usdcEthFeed, feedZero, 0, 18, 6);
    }

    function testConstructorVaultZeroNonOneSample(uint256 vaultConversionSample) public {
        vaultConversionSample = bound(vaultConversionSample, 2, type(uint256).max);

        vm.expectRevert(bytes(ErrorsLib.VAULT_CONVERSION_SAMPLE_IS_NOT_ONE));
        new ChainlinkOracle(vaultZero, daiEthFeed, feedZero, usdcEthFeed, feedZero, vaultConversionSample, 18, 6);
    }
}
