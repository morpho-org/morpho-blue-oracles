// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "../lib/forge-std/src/Test.sol";
import "../src/Chainlink4626Oracle.sol";
import "../src/libraries/ErrorsLib.sol";

AggregatorV3Interface constant feedZero = AggregatorV3Interface(address(0));
// 18 decimals of precision
AggregatorV3Interface constant daiEthFeed = AggregatorV3Interface(0x773616E4d11A78F511299002da57A0a94577F1f4);
// 18 decimals of precision
AggregatorV3Interface constant usdcEthFeed = AggregatorV3Interface(0x986b5E1e1755e3C2440e960477f25201B0a8bbD4);

ERC4626Interface constant sDaiVault = ERC4626Interface(0x83F20F44975D03b1b09e64809B757c47f942BEeA);

contract Chainlink4626OracleTest is Test {
    function setUp() public {
        vm.selectFork(vm.createFork(vm.envString("ETH_RPC_URL")));
    }

    function testSDaiEthOracle() public {
        Chainlink4626Oracle oracle = new Chainlink4626Oracle(sDaiVault, daiEthFeed, feedZero, 18, 18);
        (, int256 expectedPrice,,,) = daiEthFeed.latestRoundData();
        assertEq(
            oracle.price(),
            sDaiVault.convertToAssets(1e18) * uint256(expectedPrice) * 10 ** (36 + 18 + 0 - 18 - 18 - 18)
        );
    }

    function testSDaiUsdcOracle() public {
        Chainlink4626Oracle oracle = new Chainlink4626Oracle(sDaiVault, daiEthFeed, usdcEthFeed, 18, 6);
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
}
