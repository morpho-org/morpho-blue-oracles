// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "src/chainlink/OracleFourFeeds.sol";
import "src/chainlink/libraries/ErrorsLib.sol";

// 8 decimals of precision
AggregatorV3Interface constant btcUsdFeed = AggregatorV3Interface(0xF4030086522a5bEEa4988F8cA5B36dbC97BeE88c);
// 8 decimals of precision
AggregatorV3Interface constant usdcUsdFeed = AggregatorV3Interface(0x8fFfFfd4AfB6115b954Bd326cbe7B4BA576818f6);
// 18 decimals of precision
AggregatorV3Interface constant btcEthFeed = AggregatorV3Interface(0xdeb288F737066589598e9214E782fa5A8eD689e8);
// 8 decimals of precision
AggregatorV3Interface constant wBtcBtcFeed = AggregatorV3Interface(0xfdFD9C85aD200c506Cf9e21F1FD8dd01932FBB23);

contract OracleFourFeedsTest is Test {
    function setUp() public {
        vm.createSelectFork(vm.envString("ETH_RPC_URL"));
    }

    function testOracleWbtcUsdc() public {
        OracleFourFeeds oracle =
            new OracleFourFeeds(wBtcBtcFeed, btcUsdFeed, usdcUsdFeed, AggregatorV3Interface(address(0)), 8, 6);
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
        OracleFourFeeds oracle =
            new OracleFourFeeds(usdcUsdFeed, AggregatorV3Interface(address(0)), wBtcBtcFeed, btcUsdFeed, 6, 8);
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
        OracleFourFeeds oracle =
        new OracleFourFeeds(wBtcBtcFeed, btcEthFeed, AggregatorV3Interface(address(0)), AggregatorV3Interface(address(0)), 8, 18);
        (, int256 firstBaseAnswer,,,) = wBtcBtcFeed.latestRoundData();
        (, int256 secondBaseAnswer,,,) = btcEthFeed.latestRoundData();
        assertEq(oracle.price(), (uint256(firstBaseAnswer) * uint256(secondBaseAnswer) * 10 ** (36 + 18 - 8 - 8 - 18)));
    }
}
