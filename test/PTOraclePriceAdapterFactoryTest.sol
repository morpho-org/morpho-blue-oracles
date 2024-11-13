// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "./helpers/Constants.sol";
import "../lib/forge-std/src/Test.sol";
import "../src/pendle-pt-oracle-adapter/PTOraclePriceAdapterFactory.sol";
import "./helpers/PendleConstants.sol";
import {ChainlinkDataFeedLib} from "../src/morpho-chainlink/libraries/ChainlinkDataFeedLib.sol";

contract PTOraclePriceAdapterFactoryTest is Test {
    using ChainlinkDataFeedLib for AggregatorV3Interface;

    PTOraclePriceAdapterFactory factory;

    function setUp() public {
        vm.createSelectFork(vm.envString("ETH_RPC_URL"));
        require(block.chainid == 1, "chain isn't Ethereum");
        factory = new PTOraclePriceAdapterFactory();
    }

    function testDeployLBTCMar2025Oracle(bytes32 salt) public {
        bytes32 initCodeHash = hashInitCode(
            type(PTOraclePriceAdapter).creationCode,
            abi.encode(PT_ORACLE, LBTC_MAR2025, 900)
        );
        address expectedAddress = computeCreate2Address(
            salt,
            initCodeHash,
            address(factory)
        );

        assertFalse(factory.isPTOracle(expectedAddress), "isPTOracle");
        PTOraclePriceAdapter adapter = factory.createPTOraclePriceAdapter(
            PT_ORACLE,
            LBTC_MAR2025,
            900,
            salt
        );
        assertEq(expectedAddress, address(adapter), "computeCreate2Address");
        assertTrue(factory.isPTOracle(address(adapter)), "isPTOracle");
        assertEq(address(adapter.oracle()), address(PT_ORACLE), "PT Oracle");
        assertEq(
            address(adapter.market()),
            address(LBTC_MAR2025),
            "Pendle Market"
        );
        assertEq(adapter.duration(), 900, "Duration");

        (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        ) = adapter.latestRoundData();

        // Basic sanity check on the price
        assertTrue(answer > 0, "price should be positive");
    }
}
