// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.21;

import "../lib/forge-std/src/Test.sol";
import "../lib/forge-std/src/console2.sol";
import "../src/pendle-pt-oracle-adapter/PTOraclePriceAdapter.sol";
import "./helpers/PendleConstants.sol";

contract PTOraclePriceAdapterTest is Test {
    function setUp() public {
        uint256 forkBlock = 21173376;
        vm.createSelectFork(vm.envString("ETH_RPC_URL"), forkBlock);
        require(block.chainid == 1, "Chain isn't Ethereum");
        console2.log("PT Oracle address:", address(PT_ORACLE));
        console2.log("Current block number:", block.number);
    }

    function testLBTC_MAR2025() public {
        PTOraclePriceAdapter oracle = new PTOraclePriceAdapter(
            PT_ORACLE,
            LBTC_MAR2025,
            900
        );
        (, int256 answer, , , ) = oracle.latestRoundData();
        assertApproxEqRel(answer, 0.9824e18, 1e14);
        console2.log("LBTC_MAR2025 PT to asset rate:", answer);
    }

    function testSUSDe_MARCH2025() public {
        PTOraclePriceAdapter oracle = new PTOraclePriceAdapter(
            PT_ORACLE,
            SUSDE_MAR2025,
            900
        );
        (, int256 answer, , , ) = oracle.latestRoundData();
        assertApproxEqRel(answer, 0.9415e18, 1e14);
        console2.log("SUSDE_MAR2025 PT to asset rate:", answer);
    }

    function testPUFETH_DEC2024() public {
        PTOraclePriceAdapter oracle = new PTOraclePriceAdapter(
            PT_ORACLE,
            PUFETH_DEC2024,
            900
        );
        (, int256 answer, , , ) = oracle.latestRoundData();
        assertApproxEqRel(answer, 0.9944e18, 1e14);
        console2.log("PUFETH_DEC2024 PT to asset rate:", answer);
    }

    function testSTETH_DEC2027() public {
        PTOraclePriceAdapter oracle = new PTOraclePriceAdapter(
            PT_ORACLE,
            STETH_DEC2027,
            900
        );
        (, int256 answer, , , ) = oracle.latestRoundData();
        assertApproxEqRel(answer, 0.8520e18, 1e14);
        console2.log("STETH_DEC2027 PT to asset rate:", answer);
    }
}
