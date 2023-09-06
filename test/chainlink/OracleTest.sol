// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "src/chainlink/Oracle.sol";

AggregatorV3Interface constant stEthEthFeed = AggregatorV3Interface(0x86392dC19c0b719886221c78AB11eb8Cf5c52812); // 18 decimals of precision
AggregatorV3Interface constant usdcEthFeed = AggregatorV3Interface(0x986b5E1e1755e3C2440e960477f25201B0a8bbD4); // 18 decimals of precision
AggregatorV3Interface constant ethUsdFeed = AggregatorV3Interface(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419); // 8 decimals of precision

contract OracleTest is Test {
    function setUp() public {
        vm.selectFork(vm.createFork(vm.envString("ETH_RPC_URL")));
    }

    function testOracleStEthUsdc() public {
        Oracle oracle = new Oracle(stEthEthFeed, 18, usdcEthFeed, 6, type(uint256).max);
        (, int256 baseAnswer,,,) = stEthEthFeed.latestRoundData();
        (, int256 quoteAnswer,,,) = usdcEthFeed.latestRoundData();
        assertEq(oracle.price(), uint256(baseAnswer) * 10 ** (36 + 18 + 18 - 18 - 6) / uint256(quoteAnswer));
    }

    function testOracleEthUsd() public {
        Oracle oracle = new Oracle(ethUsdFeed, 18, AggregatorV3Interface(address(0)), 0, type(uint256).max);
        (, int256 expectedPrice,,,) = ethUsdFeed.latestRoundData();
        assertEq(oracle.price(), uint256(expectedPrice) * 10 ** (36 + 18 - 8));
    }

    function testOracleStEthEth() public {
        Oracle oracle = new Oracle(stEthEthFeed, 18, AggregatorV3Interface(address(0)), 0, type(uint256).max);
        (, int256 expectedPrice,,,) = stEthEthFeed.latestRoundData();
        assertEq(oracle.price(), uint256(expectedPrice) * 10 ** (36 + 18 - 18));
    }

    function testOracleEthStEth() public {
        Oracle oracle = new Oracle(AggregatorV3Interface(address(0)), 0, stEthEthFeed, 18, type(uint256).max);
        (, int256 expectedPrice,,,) = stEthEthFeed.latestRoundData();
        assertEq(oracle.price(), 10 ** (36 + 18 - 18) / uint256(expectedPrice));
    }
}
