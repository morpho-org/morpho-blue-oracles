// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "../lib/forge-std/src/Test.sol";
import "../src/morpho-chainlink/MorphoChainlinkOracleV2.sol";
import "./mocks/ChainlinkAggregatorMock.sol";
import "./helpers/Constants.sol";

contract MorphoChainlinkOracleV2Test is Test {
    using Math for uint256;

    function setUp() public {
        vm.createSelectFork(vm.envString("ETH_RPC_URL"));
        require(block.chainid == 1, "chain isn't Ethereum");
    }

    function testOracleWbtcUsdc() public {
        MorphoChainlinkOracleV2 oracle = new MorphoChainlinkOracleV2(
            vaultZero, 1, wBtcBtcFeed, btcUsdFeed, 8, vaultZero, 1, usdcUsdFeed, feedZero, 6
        );
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
        MorphoChainlinkOracleV2 oracle = new MorphoChainlinkOracleV2(
            vaultZero, 1, usdcUsdFeed, feedZero, 6, vaultZero, 1, wBtcBtcFeed, btcUsdFeed, 8
        );
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
        MorphoChainlinkOracleV2 oracle =
            new MorphoChainlinkOracleV2(vaultZero, 1, wBtcBtcFeed, btcEthFeed, 8, vaultZero, 1, feedZero, feedZero, 18);
        (, int256 firstBaseAnswer,,,) = wBtcBtcFeed.latestRoundData();
        (, int256 secondBaseAnswer,,,) = btcEthFeed.latestRoundData();
        assertEq(oracle.price(), (uint256(firstBaseAnswer) * uint256(secondBaseAnswer) * 10 ** (36 + 18 - 8 - 8 - 18)));
    }

    function testOracleStEthUsdc() public {
        MorphoChainlinkOracleV2 oracle = new MorphoChainlinkOracleV2(
            vaultZero, 1, stEthEthFeed, feedZero, 18, vaultZero, 1, usdcEthFeed, feedZero, 6
        );
        (, int256 baseAnswer,,,) = stEthEthFeed.latestRoundData();
        (, int256 quoteAnswer,,,) = usdcEthFeed.latestRoundData();
        assertEq(oracle.price(), uint256(baseAnswer) * 10 ** (36 + 18 + 6 - 18 - 18) / uint256(quoteAnswer));
    }

    function testOracleEthUsd() public {
        MorphoChainlinkOracleV2 oracle =
            new MorphoChainlinkOracleV2(vaultZero, 1, ethUsdFeed, feedZero, 18, vaultZero, 1, feedZero, feedZero, 0);
        (, int256 expectedPrice,,,) = ethUsdFeed.latestRoundData();
        assertEq(oracle.price(), uint256(expectedPrice) * 10 ** (36 - 18 - 8));
    }

    function testOracleStEthEth() public {
        MorphoChainlinkOracleV2 oracle =
            new MorphoChainlinkOracleV2(vaultZero, 1, stEthEthFeed, feedZero, 18, vaultZero, 1, feedZero, feedZero, 18);
        (, int256 expectedPrice,,,) = stEthEthFeed.latestRoundData();
        assertEq(oracle.price(), uint256(expectedPrice) * 10 ** (36 + 18 - 18 - 18));
        assertApproxEqRel(oracle.price(), 1e36, 0.01 ether);
    }

    function testOracleEthStEth() public {
        MorphoChainlinkOracleV2 oracle =
            new MorphoChainlinkOracleV2(vaultZero, 1, feedZero, feedZero, 18, vaultZero, 1, stEthEthFeed, feedZero, 18);
        (, int256 expectedPrice,,,) = stEthEthFeed.latestRoundData();
        assertEq(oracle.price(), 10 ** (36 + 18 + 18 - 18) / uint256(expectedPrice));
        assertApproxEqRel(oracle.price(), 1e36, 0.01 ether);
    }

    function testOracleUsdcUsd() public {
        MorphoChainlinkOracleV2 oracle =
            new MorphoChainlinkOracleV2(vaultZero, 1, usdcUsdFeed, feedZero, 6, vaultZero, 1, feedZero, feedZero, 0);
        assertApproxEqRel(oracle.price(), 1e36 / 1e6, 0.01 ether);
    }

    function testNegativeAnswer(int256 price) public {
        price = bound(price, type(int256).min, -1);
        ChainlinkAggregatorMock aggregator = new ChainlinkAggregatorMock();
        MorphoChainlinkOracleV2 oracle = new MorphoChainlinkOracleV2(
            vaultZero, 1, AggregatorV3Interface(address(aggregator)), feedZero, 18, vaultZero, 1, feedZero, feedZero, 0
        );
        aggregator.setAnwser(price);
        vm.expectRevert(bytes(ErrorsLib.NEGATIVE_ANSWER));
        oracle.price();
    }

    function testSDaiEthOracle() public {
        MorphoChainlinkOracleV2 oracle = new MorphoChainlinkOracleV2(
            sDaiVault, 1e18, daiEthFeed, feedZero, 18, vaultZero, 1, feedZero, feedZero, 18
        );
        (, int256 expectedPrice,,,) = daiEthFeed.latestRoundData();
        assertEq(
            oracle.price(),
            sDaiVault.convertToAssets(1e18) * uint256(expectedPrice) * 10 ** (36 + 18 + 0 - 18 - 18 - 18)
        );
    }

    function testSDaiUsdcOracle() public {
        MorphoChainlinkOracleV2 oracle = new MorphoChainlinkOracleV2(
            sDaiVault, 1e18, daiEthFeed, feedZero, 18, vaultZero, 1, usdcEthFeed, feedZero, 6
        );
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

    function testEthSDaiOracle() public {
        MorphoChainlinkOracleV2 oracle = new MorphoChainlinkOracleV2(
            vaultZero, 1, feedZero, feedZero, 18, sDaiVault, 1e18, daiEthFeed, feedZero, 18
        );
        (, int256 quoteAnswer,,,) = daiEthFeed.latestRoundData();
        assertEq(
            oracle.price(),
            // 1e(36 + dQ1 + fpQ1 + fpQ2 - dB1 - fpB1 - fpB2) * qCS / bCS
            10 ** (36 + 18 + 18 + 0 - 18 - 0 - 0) * 1e18 / (sDaiVault.convertToAssets(1e18) * uint256(quoteAnswer))
        );
    }

    function testUsdcSDaiOracle() public {
        MorphoChainlinkOracleV2 oracle = new MorphoChainlinkOracleV2(
            vaultZero, 1, usdcEthFeed, feedZero, 6, sDaiVault, 1e18, daiEthFeed, feedZero, 18
        );
        (, int256 baseAnswer,,,) = usdcEthFeed.latestRoundData();
        (, int256 quoteAnswer,,,) = daiEthFeed.latestRoundData();
        // 1e(36 + dQ1 + fpQ1 + fpQ2 - dB1 - fpB1 - fpB2) * qCS / bCS
        uint256 scaleFactor = 10 ** (36 + 18 + 18 + 0 - 6 - 18 - 0) * 1e18;
        assertEq(
            oracle.price(),
            scaleFactor.mulDiv(uint256(baseAnswer), (sDaiVault.convertToAssets(1e18) * uint256(quoteAnswer)))
        );
        // DAI has 12 more decimals than USDC.
        uint256 expectedPrice = 10 ** (36 + 12);
        // Admit a 50% interest gain before breaking this test.
        uint256 deviation = 0.33 ether;
        assertApproxEqRel(oracle.price(), expectedPrice, deviation);
    }

    function testSfrxEthSDaiOracle() public {
        MorphoChainlinkOracleV2 oracle = new MorphoChainlinkOracleV2(
            sfrxEthVault, 1e18, feedZero, feedZero, 18, sDaiVault, 1e18, daiEthFeed, feedZero, 18
        );
        (, int256 quoteAnswer,,,) = daiEthFeed.latestRoundData();
        // 1e(36 + dQ1 + fpQ1 + fpQ2 - dB1 - fpB1 - fpB2) * qCS / bCS
        uint256 scaleFactor = 10 ** (36 + 18 + 18 + 0 - 18 - 0 - 0) * 1e18 / 1e18;
        assertEq(
            oracle.price(),
            scaleFactor.mulDiv(
                sfrxEthVault.convertToAssets(1e18), (sDaiVault.convertToAssets(1e18) * uint256(quoteAnswer))
            )
        );
    }

    function testConstructorZeroVaultConversionSample() public {
        vm.expectRevert(bytes(ErrorsLib.VAULT_CONVERSION_SAMPLE_IS_ZERO));
        new MorphoChainlinkOracleV2(sDaiVault, 0, daiEthFeed, feedZero, 18, vaultZero, 1, usdcEthFeed, feedZero, 6);
        vm.expectRevert(bytes(ErrorsLib.VAULT_CONVERSION_SAMPLE_IS_ZERO));
        new MorphoChainlinkOracleV2(vaultZero, 1, daiEthFeed, feedZero, 18, sDaiVault, 0, usdcEthFeed, feedZero, 6);
    }

    function testConstructorVaultZeroNotOneSample(uint256 vaultConversionSample) public {
        vaultConversionSample = bound(vaultConversionSample, 2, type(uint256).max);

        vm.expectRevert(bytes(ErrorsLib.VAULT_CONVERSION_SAMPLE_IS_NOT_ONE));
        new MorphoChainlinkOracleV2(vaultZero, 0, daiEthFeed, feedZero, 18, vaultZero, 1, usdcEthFeed, feedZero, 6);
        vm.expectRevert(bytes(ErrorsLib.VAULT_CONVERSION_SAMPLE_IS_NOT_ONE));
        new MorphoChainlinkOracleV2(vaultZero, 1, daiEthFeed, feedZero, 18, vaultZero, 0, usdcEthFeed, feedZero, 6);
    }
}
