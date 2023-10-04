// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "src/chainlink/ChainlinkOracle.sol";
import "src/chainlink/libraries/ErrorsLib.sol";

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

contract FakeAggregator {
    int256 public answer;

    function setAnwser(int256 newAnswer) external {
        answer = newAnswer;
    }

    function latestRoundData() external view returns (uint80, int256, uint256, uint256, uint80) {
        return (0, answer, 0, 0, 0);
    }

    function decimals() external pure returns (uint256) {
        return 8;
    }
}

contract ChainlinkOracleTest is Test {
    function setUp() public {
        vm.createSelectFork(vm.envString("ETH_RPC_URL"));
    }

    function testOracleWbtcUsdc() public {
        ChainlinkOracle oracle =
            new ChainlinkOracle(wBtcBtcFeed, btcUsdFeed, usdcUsdFeed, feedZero, 8, 6);
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
            new ChainlinkOracle(usdcUsdFeed, feedZero, wBtcBtcFeed, btcUsdFeed, 6, 8);
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
        new ChainlinkOracle(wBtcBtcFeed, btcEthFeed, feedZero, feedZero, 8, 18);
        (, int256 firstBaseAnswer,,,) = wBtcBtcFeed.latestRoundData();
        (, int256 secondBaseAnswer,,,) = btcEthFeed.latestRoundData();
        assertEq(oracle.price(), (uint256(firstBaseAnswer) * uint256(secondBaseAnswer) * 10 ** (36 + 18 - 8 - 8 - 18)));
    }

    function testOracleStEthUsdc() public {
        ChainlinkOracle oracle = new ChainlinkOracle(stEthEthFeed, feedZero, usdcEthFeed, feedZero, 18, 6);
        (, int256 baseAnswer,,,) = stEthEthFeed.latestRoundData();
        (, int256 quoteAnswer,,,) = usdcEthFeed.latestRoundData();
        assertEq(oracle.price(), uint256(baseAnswer) * 10 ** (36 + 18 + 6 - 18 - 18) / uint256(quoteAnswer));
    }

    function testOracleEthUsd() public {
        ChainlinkOracle oracle = new ChainlinkOracle(ethUsdFeed, feedZero, feedZero, feedZero, 18, 0);
        (, int256 expectedPrice,,,) = ethUsdFeed.latestRoundData();
        assertEq(oracle.price(), uint256(expectedPrice) * 10 ** (36 - 18 - 8));
    }

    function testOracleStEthEth() public {
        ChainlinkOracle oracle = new ChainlinkOracle(stEthEthFeed, feedZero, feedZero, feedZero, 18, 18);
        (, int256 expectedPrice,,,) = stEthEthFeed.latestRoundData();
        assertEq(oracle.price(), uint256(expectedPrice) * 10 ** (36 + 18 - 18 - 18));
        assertApproxEqRel(oracle.price(), 1e36, 0.01 ether);
    }

    function testOracleEthStEth() public {
        ChainlinkOracle oracle = new ChainlinkOracle(feedZero, feedZero, stEthEthFeed, feedZero, 18, 18);
        (, int256 expectedPrice,,,) = stEthEthFeed.latestRoundData();
        assertEq(oracle.price(), 10 ** (36 + 18 + 18 - 18) / uint256(expectedPrice));
        assertApproxEqRel(oracle.price(), 1e36, 0.01 ether);
    }

    function testOracleUsdcUsd() public {
        ChainlinkOracle oracle = new ChainlinkOracle(usdcUsdFeed, feedZero, feedZero, feedZero, 6, 0);
        assertApproxEqRel(oracle.price(), 1e36 / 1e6, 0.01 ether);
    }

    function testNegativeAnswer(int256 price) public {
        price = bound(price, type(int256).min, -1);
        FakeAggregator aggregator = new FakeAggregator();
        ChainlinkOracle oracle =
            new ChainlinkOracle(AggregatorV3Interface(address(aggregator)), feedZero, feedZero, feedZero, 18, 0);
        aggregator.setAnwser(price);
        vm.expectRevert(bytes(ErrorsLib.NEGATIVE_ANSWER));
        oracle.price();
    }
}
