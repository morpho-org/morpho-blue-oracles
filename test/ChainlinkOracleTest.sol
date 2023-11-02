// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "../lib/forge-std/src/Test.sol";
import "../src/ChainlinkOracle.sol";
import "../src/ChainlinkOracleAlt.sol";
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
    function setUp() public {
        vm.createSelectFork(vm.envString("ETH_RPC_URL"));
    }

    uint256 private constant altOraclePrecision = 0.001 ether;

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
        ChainlinkOracleAlt oracleAlt =
            new ChainlinkOracleAlt(vaultZero, wBtcBtcFeed, 8, btcUsdFeed, 8, usdcUsdFeed, 6, feedZero, 0, 0);
        assertApproxEqRel(oracle.price(), oracleAlt.price(), altOraclePrecision);
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
        ChainlinkOracleAlt oracleAlt =
            new ChainlinkOracleAlt(vaultZero, usdcUsdFeed, 6, feedZero, 0, wBtcBtcFeed, 8, btcUsdFeed, 8, 0);
        assertApproxEqRel(oracle.price(), oracleAlt.price(), altOraclePrecision);
    }

    function testOracleWbtcEth() public {
        ChainlinkOracle oracle = new ChainlinkOracle(vaultZero,wBtcBtcFeed, btcEthFeed, feedZero, feedZero, 1, 8, 18);
        (, int256 firstBaseAnswer,,,) = wBtcBtcFeed.latestRoundData();
        (, int256 secondBaseAnswer,,,) = btcEthFeed.latestRoundData();
        assertEq(oracle.price(), (uint256(firstBaseAnswer) * uint256(secondBaseAnswer) * 10 ** (36 + 18 - 8 - 8 - 18)));
        ChainlinkOracleAlt oracleAlt =
            new ChainlinkOracleAlt(vaultZero, wBtcBtcFeed, 8, btcEthFeed, 8, feedZero, 0, feedZero, 0, 18);
        assertApproxEqRel(oracle.price(), oracleAlt.price(), altOraclePrecision);
    }

    function testOracleStEthUsdc() public {
        ChainlinkOracle oracle = new ChainlinkOracle(vaultZero, stEthEthFeed, feedZero, usdcEthFeed, feedZero, 1, 18, 6);
        (, int256 baseAnswer,,,) = stEthEthFeed.latestRoundData();
        (, int256 quoteAnswer,,,) = usdcEthFeed.latestRoundData();
        assertEq(oracle.price(), uint256(baseAnswer) * 10 ** (36 + 18 + 6 - 18 - 18) / uint256(quoteAnswer));
        ChainlinkOracleAlt oracleAlt =
            new ChainlinkOracleAlt(vaultZero, stEthEthFeed, 18, feedZero, 0, usdcEthFeed, 6, feedZero, 0, 18);
        assertApproxEqRel(oracle.price(), oracleAlt.price(), altOraclePrecision);
    }

    function testOracleEthUsd() public {
        ChainlinkOracle oracle = new ChainlinkOracle(vaultZero, ethUsdFeed, feedZero, feedZero, feedZero, 1, 18, 0);
        (, int256 expectedPrice,,,) = ethUsdFeed.latestRoundData();
        assertEq(oracle.price(), uint256(expectedPrice) * 10 ** (36 - 18 - 8));
        ChainlinkOracleAlt oracleAlt =
            new ChainlinkOracleAlt(vaultZero, ethUsdFeed, 18, feedZero, 0, feedZero, 0, feedZero, 0, 0);
        assertApproxEqRel(oracle.price(), oracleAlt.price(), altOraclePrecision);
    }

    function testOracleStEthEth() public {
        ChainlinkOracle oracle = new ChainlinkOracle(vaultZero, stEthEthFeed, feedZero, feedZero, feedZero, 1, 18, 18);
        (, int256 expectedPrice,,,) = stEthEthFeed.latestRoundData();
        assertEq(oracle.price(), uint256(expectedPrice) * 10 ** (36 + 18 - 18 - 18));
        assertApproxEqRel(oracle.price(), 1e36, 0.01 ether);
        ChainlinkOracleAlt oracleAlt =
            new ChainlinkOracleAlt(vaultZero, stEthEthFeed, 18, feedZero, 0, feedZero, 0, feedZero, 0, 18);
        assertApproxEqRel(oracle.price(), oracleAlt.price(), altOraclePrecision);
    }

    function testOracleEthStEth() public {
        ChainlinkOracle oracle = new ChainlinkOracle(vaultZero, feedZero, feedZero, stEthEthFeed, feedZero, 1, 18, 18);
        (, int256 expectedPrice,,,) = stEthEthFeed.latestRoundData();
        assertEq(oracle.price(), 10 ** (36 + 18 + 18 - 18) / uint256(expectedPrice));
        assertApproxEqRel(oracle.price(), 1e36, 0.01 ether);
        ChainlinkOracleAlt oracleAlt =
            new ChainlinkOracleAlt(vaultZero, feedZero, 0, feedZero, 0, stEthEthFeed, 18, feedZero, 0, 18);
        assertApproxEqRel(oracle.price(), oracleAlt.price(), altOraclePrecision);
    }

    function testOracleUsdcUsd() public {
        ChainlinkOracle oracle = new ChainlinkOracle(vaultZero, usdcUsdFeed, feedZero, feedZero, feedZero, 1, 6, 0);
        assertApproxEqRel(oracle.price(), 1e36 / 1e6, 0.01 ether);
        ChainlinkOracleAlt oracleAlt =
            new ChainlinkOracleAlt(vaultZero, usdcUsdFeed, 6, feedZero, 0, feedZero, 0, feedZero, 0, 0);
        assertApproxEqRel(oracle.price(), oracleAlt.price(), altOraclePrecision);
    }

    function testNegativeAnswer(int256 price) public {
        price = bound(price, type(int256).min, -1);
        ChainlinkAggregatorMock aggregator = new ChainlinkAggregatorMock();
        ChainlinkOracle oracle =
        new ChainlinkOracle(vaultZero, AggregatorV3Interface(address(aggregator)), feedZero, feedZero, feedZero, 1, 18, 0);
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
        ChainlinkOracleAlt oracleAlt =
            new ChainlinkOracleAlt(sDaiVault, daiEthFeed, 18, feedZero, 0, feedZero, 0, feedZero, 0, 18);
        assertApproxEqRel(oracle.price(), oracleAlt.price(), altOraclePrecision);
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
        ChainlinkOracleAlt oracleAlt =
            new ChainlinkOracleAlt(sDaiVault, daiEthFeed, 18, feedZero, 0, usdcEthFeed, 6, feedZero, 0, 18);
        assertApproxEqRel(oracle.price(), oracleAlt.price(), altOraclePrecision);
    }

    function testConstructorVaultZeroNonOneSample(uint256 vaultConversionSample) public {
        vm.assume(vaultConversionSample != 1);
        vm.expectRevert(bytes(ErrorsLib.VAULT_CONVERSION_SAMPLE_IS_NOT_ONE));
        new ChainlinkOracle(vaultZero, daiEthFeed, feedZero, usdcEthFeed, feedZero, vaultConversionSample, 18, 6);
    }
}
