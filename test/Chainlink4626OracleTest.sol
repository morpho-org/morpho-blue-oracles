// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "../lib/forge-std/src/Test.sol";
import "../src/4626ChainlinkOracle.sol";
import "../src/libraries/ErrorsLib.sol";

// 18 decimals of precision
AggregatorV3Interface constant daiEthFeed = AggregatorV3Interface(0x773616E4d11A78F511299002da57A0a94577F1f4);
// 18 decimals of precision
AggregatorV3Interface constant usdcEthFeed = AggregatorV3Interface(0x986b5E1e1755e3C2440e960477f25201B0a8bbD4);

ERC4626 constant sDaiVault = ERC4626(0x83F20F44975D03b1b09e64809B757c47f942BEeA);

contract OracleTest is Test {
    function setUp() public {
        vm.selectFork(vm.createFork(vm.envString("ETH_RPC_URL")));
    }

    function testSdaiEthOracle() public {
        OracleNonRebasing oracle =
            new OracleNonRebasing(sDaiVault, daiEthFeed, AggregatorV3Interface(address(0)), 18, 0);
        (, int256 expectedPrice,,,) = daiEthFeed.latestRoundData();
        assertEq(oracle.price(), sDaiVault.convertToAssets(1e18) * uint256(expectedPrice) * 10 ** (36 + 0 - 18 - 0));
    }
}
