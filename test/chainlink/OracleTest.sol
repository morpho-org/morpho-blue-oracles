// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "src/chainlink/Oracle.sol";
import "src/chainlink/libraries/ErrorsLib.sol";

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

contract OracleTest is Test {
    function setUp() public {
        vm.selectFork(vm.createFork(vm.envString("ETH_RPC_URL")));
    }

    function testOracleStEthUsdc() public {
        Oracle oracle = new Oracle(stEthEthFeed, 18, usdcEthFeed, 6);
        (, int256 baseAnswer,,,) = stEthEthFeed.latestRoundData();
        (, int256 quoteAnswer,,,) = usdcEthFeed.latestRoundData();
        assertEq(oracle.price(), uint256(baseAnswer) * 10 ** (36 + 18 + 18 - 18 - 6) / uint256(quoteAnswer));
    }

    function testOracleEthUsd() public {
        Oracle oracle = new Oracle(ethUsdFeed, 18, AggregatorV3Interface(address(0)), 0);
        (, int256 expectedPrice,,,) = ethUsdFeed.latestRoundData();
        assertEq(oracle.price(), uint256(expectedPrice) * 10 ** (36 + 18 - 8));
    }

    function testOracleStEthEth() public {
        Oracle oracle = new Oracle(stEthEthFeed, 18, AggregatorV3Interface(address(0)), 0);
        (, int256 expectedPrice,,,) = stEthEthFeed.latestRoundData();
        assertEq(oracle.price(), uint256(expectedPrice) * 10 ** (36 + 18 - 18));
    }

    function testOracleEthStEth() public {
        Oracle oracle = new Oracle(AggregatorV3Interface(address(0)), 0, stEthEthFeed, 18);
        (, int256 expectedPrice,,,) = stEthEthFeed.latestRoundData();
        assertEq(oracle.price(), 10 ** (36 + 18 - 18) / uint256(expectedPrice));
    }

    function testNegativeAnswer() public {
        FakeAggregator aggregator = new FakeAggregator();
        Oracle oracle = new Oracle(AggregatorV3Interface(address(aggregator)), 18, AggregatorV3Interface(address(0)), 0);
        aggregator.setAnwser(-1);
        vm.expectRevert(bytes(ErrorsLib.NEGATIVE_ANSWER));
        oracle.price();
    }
}
