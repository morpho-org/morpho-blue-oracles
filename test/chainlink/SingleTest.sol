// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "src/chainlink/Single.sol";

AggregatorV3Interface constant ethUsdFeed = AggregatorV3Interface(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419); // 8 decimals of precision
AggregatorV3Interface constant stEthEthFeed = AggregatorV3Interface(0x86392dC19c0b719886221c78AB11eb8Cf5c52812); // 18 decimals of precision

contract SingleOracleTest is Test {

    function setUp() public {
        vm.selectFork(vm.createFork(vm.envString("ETH_RPC_URL")));
    }

    function testOracleEthUsd() public {
        Oracle oracle = new Oracle(ethUsdFeed, 18);
        (, int256 expectedPrice,,,) = ethUsdFeed.latestRoundData();
        assertEq(oracle.price(), uint256(expectedPrice) * 10**(18 + 36 - 8));
    }

    function testOraclStEthEth() public {
        Oracle oracle = new Oracle(stEthEthFeed, 18);
        (, int256 expectedPrice,,,) = stEthEthFeed.latestRoundData();
        assertEq(oracle.price(), uint256(expectedPrice) * 10**(18 + 36 - 18));
    } 
}
