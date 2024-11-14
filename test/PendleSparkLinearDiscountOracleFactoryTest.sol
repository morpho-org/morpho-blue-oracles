// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.21;

import "../lib/forge-std/src/Test.sol";
import "../src/pendle-pt-oracle-adapter/PendleSparkLinearDiscountOracleFactory.sol";
import "../lib/forge-std/src/console2.sol";
import "./helpers/PendleConstants.sol";
import {PendleSparkLinearDiscountOracle} from "pendle-core-v2-public/oracles/PendleSparkLinearDiscountOracle.sol";
import {PTExpiry} from "pendle-core-v2-public/oracles/PendleSparkLinearDiscountOracle.sol";

contract PendleSparkLinearDiscountOracleFactoryTest is Test {
    PendleSparkLinearDiscountOracleFactory factory;

    uint256 constant BASE_DISCOUNT_PER_YEAR = 0.2e18; // 10% discount

    function setUp() public {
        vm.createSelectFork(vm.envString("ETH_RPC_URL"));
        require(block.chainid == 1, "chain isn't Ethereum");
        factory = new PendleSparkLinearDiscountOracleFactory();
    }

    function testDeployLBTCMar2025DiscountOracle(bytes32 salt) public {
        bytes32 initCodeHash = hashInitCode(
            type(PendleSparkLinearDiscountOracle).creationCode,
            abi.encode(LBTC_MAR2025, BASE_DISCOUNT_PER_YEAR)
        );
        address expectedAddress = computeCreate2Address(
            salt,
            initCodeHash,
            address(factory)
        );

        assertFalse(
            factory.isPendleSparkLinearDiscountOracle(expectedAddress),
            "isPendleSparkLinearDiscountOracle"
        );

        PendleSparkLinearDiscountOracle oracle = factory
            .createPendleSparkLinearDiscountOracle(
                LBTC_MAR2025,
                BASE_DISCOUNT_PER_YEAR,
                salt
            );

        assertEq(expectedAddress, address(oracle), "computeCreate2Address");
        assertTrue(
            factory.isPendleSparkLinearDiscountOracle(address(oracle)),
            "isPendleSparkLinearDiscountOracle"
        );

        // Test oracle parameters
        assertEq(oracle.PT(), LBTC_MAR2025, "PT address");
        assertEq(
            oracle.baseDiscountPerYear(),
            BASE_DISCOUNT_PER_YEAR,
            "Base discount"
        );
        assertEq(
            oracle.maturity(),
            PTExpiry(LBTC_MAR2025).expiry(),
            "Maturity"
        );

        (, int256 answer, , , ) = oracle.latestRoundData();
        assertGt(answer, 0.9e18, "Price should be greater than 0.9");
        assertLt(answer, 1e18, "Price should be less than 1");
        console2.log(
            "LBTC_MAR2025 Pendle Spark Linear Discount Oracle price:",
            answer
        );
    }
}
