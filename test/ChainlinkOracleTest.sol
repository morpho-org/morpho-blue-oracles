// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "../lib/forge-std/src/Test.sol";
import "../src/ChainlinkOracle.sol";
import "../src/libraries/ErrorsLib.sol";
import "./mocks/ChainlinkAggregatorMock.sol";

AggregatorV3Interface constant feedZero = AggregatorV3Interface(address(0));
// 8 decimals of precision
AggregatorV3Interface constant btcUsdFeed = AggregatorV3Interface(0xF4030086522a5bEEa4988F8cA5B36dbC97BeE88c);
// 8 decimals of precision
AggregatorV3Interface constant usdcUsdFeed = AggregatorV3Interface(0x8fFfFfd4AfB6115b954Bd326cbe7B4BA576818f6);
// 18 decimals of precision
AggregatorV3Interface constant btcEthFeed = AggregatorV3Interface(0xdeb288F737066589598e9214E782fa5A8eD689e8);
// 8 decimals of precision
AggregatorV3Interface constant wBtcBtcFeed = AggregatorV3Interface(0xfdFD9C85aD200c506Cf9e21F1FD8dd01932FBB23);
// 18 decimals of precision
AggregatorV3Interface constant stEthEthFeed = AggregatorV3Interface(0x86392dC19c0b719886221c78AB11eb8Cf5c52812);
// 18 decimals of precision
AggregatorV3Interface constant usdcEthFeed = AggregatorV3Interface(0x986b5E1e1755e3C2440e960477f25201B0a8bbD4);
// 8 decimals of precision
AggregatorV3Interface constant ethUsdFeed = AggregatorV3Interface(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419);
// 18 decimals of precision
AggregatorV3Interface constant daiEthFeed = AggregatorV3Interface(0x773616E4d11A78F511299002da57A0a94577F1f4);

IERC4626 constant vaultZero = IERC4626(address(0));
IERC4626 constant sDaiVault = IERC4626(0x83F20F44975D03b1b09e64809B757c47f942BEeA);

contract ChainlinkOracleTest is Test {
    using Math for uint256;

    function setUp() public {
        vm.createSelectFork(vm.envString("ETH_RPC_URL"));
    }

    function testOracleWbtcUsdc() public {
        ChainlinkOracle oracle =
            new ChainlinkOracle(vaultZero, 1, vaultZero, 1, wBtcBtcFeed, btcUsdFeed, usdcUsdFeed, feedZero, 8, 6);
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
        ChainlinkOracle oracle =
            new ChainlinkOracle(vaultZero, 1, vaultZero, 1, usdcUsdFeed, feedZero, wBtcBtcFeed, btcUsdFeed, 6, 8);
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
        ChainlinkOracle oracle =
            new ChainlinkOracle(vaultZero, 1, vaultZero, 1, wBtcBtcFeed, btcEthFeed, feedZero, feedZero, 8, 18);
        (, int256 firstBaseAnswer,,,) = wBtcBtcFeed.latestRoundData();
        (, int256 secondBaseAnswer,,,) = btcEthFeed.latestRoundData();
        assertEq(oracle.price(), (uint256(firstBaseAnswer) * uint256(secondBaseAnswer) * 10 ** (36 + 18 - 8 - 8 - 18)));
    }

    function testOracleStEthUsdc() public {
        ChainlinkOracle oracle =
            new ChainlinkOracle(vaultZero, 1, vaultZero, 1, stEthEthFeed, feedZero, usdcEthFeed, feedZero, 18, 6);
        (, int256 baseAnswer,,,) = stEthEthFeed.latestRoundData();
        (, int256 quoteAnswer,,,) = usdcEthFeed.latestRoundData();
        assertEq(oracle.price(), uint256(baseAnswer) * 10 ** (36 + 18 + 6 - 18 - 18) / uint256(quoteAnswer));
    }

    function testOracleEthUsd() public {
        ChainlinkOracle oracle =
            new ChainlinkOracle(vaultZero, 1, vaultZero, 1, ethUsdFeed, feedZero, feedZero, feedZero, 18, 0);
        (, int256 expectedPrice,,,) = ethUsdFeed.latestRoundData();
        assertEq(oracle.price(), uint256(expectedPrice) * 10 ** (36 - 18 - 8));
    }

    function testOracleStEthEth() public {
        ChainlinkOracle oracle =
            new ChainlinkOracle(vaultZero, 1, vaultZero, 1, stEthEthFeed, feedZero, feedZero, feedZero, 18, 18);
        (, int256 expectedPrice,,,) = stEthEthFeed.latestRoundData();
        assertEq(oracle.price(), uint256(expectedPrice) * 10 ** (36 + 18 - 18 - 18));
        assertApproxEqRel(oracle.price(), 1e36, 0.01 ether);
    }

    function testOracleEthStEth() public {
        ChainlinkOracle oracle =
            new ChainlinkOracle(vaultZero, 1, vaultZero, 1, feedZero, feedZero, stEthEthFeed, feedZero, 18, 18);
        (, int256 expectedPrice,,,) = stEthEthFeed.latestRoundData();
        assertEq(oracle.price(), 10 ** (36 + 18 + 18 - 18) / uint256(expectedPrice));
        assertApproxEqRel(oracle.price(), 1e36, 0.01 ether);
    }

    function testOracleUsdcUsd() public {
        ChainlinkOracle oracle =
            new ChainlinkOracle(vaultZero, 1, vaultZero, 1, usdcUsdFeed, feedZero, feedZero, feedZero, 6, 0);
        assertApproxEqRel(oracle.price(), 1e36 / 1e6, 0.01 ether);
    }

    function testNegativeAnswer(int256 price) public {
        price = bound(price, type(int256).min, -1);
        ChainlinkAggregatorMock aggregator = new ChainlinkAggregatorMock();
        ChainlinkOracle oracle = new ChainlinkOracle(
            vaultZero, 1, vaultZero, 1, AggregatorV3Interface(address(aggregator)), feedZero, feedZero, feedZero, 18, 0
        );
        aggregator.setAnwser(price);
        vm.expectRevert(bytes(ErrorsLib.NEGATIVE_ANSWER));
        oracle.price();
    }

    function testSDaiEthOracle() public {
        ChainlinkOracle oracle =
            new ChainlinkOracle(sDaiVault, 10 ** 18, vaultZero, 1, daiEthFeed, feedZero, feedZero, feedZero, 18, 18);
        (, int256 expectedPrice,,,) = daiEthFeed.latestRoundData();
        assertEq(
            oracle.price(),
            sDaiVault.convertToAssets(1e18) * uint256(expectedPrice) * 10 ** (36 + 18 + 0 - 18 - 18 - 18)
        );
    }

    function testSDaiUsdcOracle() public {
        ChainlinkOracle oracle =
            new ChainlinkOracle(sDaiVault, 10 ** 18, vaultZero, 1, daiEthFeed, feedZero, usdcEthFeed, feedZero, 18, 6);
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
        ChainlinkOracle oracle =
            new ChainlinkOracle(vaultZero, 1, sDaiVault, 1e18, feedZero, feedZero, daiEthFeed, feedZero, 18, 18);
        (, int256 expectedPrice,,,) = daiEthFeed.latestRoundData();
        assertEq(
            oracle.price(),
            // 1e(36 + dQ1 + fpQ1 + fpQ2 - dB1 - fpB1 - fpB2) * qCS / bCS
            10 ** (36 + 18 + 18 + 0 - 18 - 0 - 0) * 1e18 / (sDaiVault.convertToAssets(1e18) * uint256(expectedPrice))
        );
    }

    function testUsdcSDaiOracle() public {
        ChainlinkOracle oracle =
            new ChainlinkOracle(vaultZero, 1, sDaiVault, 1e18, usdcEthFeed, feedZero, daiEthFeed, feedZero, 6, 18);
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
        uint256 deviation = 0.66 ether;
        assertApproxEqRel(oracle.price(), expectedPrice, deviation);
    }

    function testConstructorZeroVaultConversionSample() public {
        vm.expectRevert(bytes(ErrorsLib.VAULT_CONVERSION_SAMPLE_IS_ZERO));
        new ChainlinkOracle(sDaiVault, 0, vaultZero, 1, daiEthFeed, feedZero, usdcEthFeed, feedZero, 18, 6);
        vm.expectRevert(bytes(ErrorsLib.VAULT_CONVERSION_SAMPLE_IS_ZERO));
        new ChainlinkOracle(vaultZero, 1, sDaiVault, 0, daiEthFeed, feedZero, usdcEthFeed, feedZero, 18, 6);
    }

    function testConstructorVaultZeroNotOneSample(uint256 vaultConversionSample) public {
        vaultConversionSample = bound(vaultConversionSample, 2, type(uint256).max);

        vm.expectRevert(bytes(ErrorsLib.VAULT_CONVERSION_SAMPLE_IS_NOT_ONE));
        new ChainlinkOracle(vaultZero, 0, vaultZero, 1, daiEthFeed, feedZero, usdcEthFeed, feedZero, 18, 6);
        vm.expectRevert(bytes(ErrorsLib.VAULT_CONVERSION_SAMPLE_IS_NOT_ONE));
        new ChainlinkOracle(vaultZero, 1, vaultZero, 0, daiEthFeed, feedZero, usdcEthFeed, feedZero, 18, 6);
    }
}
