// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "./helpers/Constants.sol";
import "../lib/forge-std/src/Test.sol";
import "../src/morpho-chainlink/MorphoChainlinkOracleV2Factory.sol";
import {ChainlinkDataFeedLib} from "../src/morpho-chainlink/libraries/ChainlinkDataFeedLib.sol";

contract ChainlinkOracleFactoryTest is Test {
    using ChainlinkDataFeedLib for AggregatorV3Interface;

    MorphoChainlinkOracleV2Factory factory;

    function setUp() public {
        vm.createSelectFork(vm.envString("ETH_RPC_URL"));
        require(block.chainid == 1, "chain isn't Ethereum");
        factory = new MorphoChainlinkOracleV2Factory();
    }

    function testDeploySDaiUsdcOracle(bytes32 salt) public {
        bytes32 initCodeHash = hashInitCode(
            type(MorphoChainlinkOracleV2).creationCode,
            abi.encode(sDaiVault, 1e18, daiEthFeed, feedZero, 18, vaultZero, 1, usdcEthFeed, feedZero, 6)
        );
        address expectedAddress = computeCreate2Address(salt, initCodeHash, address(factory));

        assertFalse(factory.isMorphoChainlinkOracleV2(expectedAddress), "isChainlinkOracle");

        // vm.expectEmit(address(factory));
        // emit IMorphoChainlinkOracleV2Factory.CreateMorphoChainlinkOracleV2(address(this), expectedAddress);
        IMorphoChainlinkOracleV2 oracle = factory.createMorphoChainlinkOracleV2(
            sDaiVault, 1e18, daiEthFeed, feedZero, 18, vaultZero, 1, usdcEthFeed, feedZero, 6, salt
        );

        assertEq(expectedAddress, address(oracle), "computeCreate2Address");

        assertTrue(factory.isMorphoChainlinkOracleV2(address(oracle)), "isChainlinkOracle");

        uint256 scaleFactor = 10 ** (36 + 6 + 18 - 18 - 18 - 18);

        assertEq(address(oracle.BASE_VAULT()), address(sDaiVault), "BASE_VAULT");
        assertEq(oracle.BASE_VAULT_CONVERSION_SAMPLE(), 1e18, "BASE_VAULT_CONVERSION_SAMPLE");
        assertEq(address(oracle.QUOTE_VAULT()), address(vaultZero), "QUOTE_VAULT");
        assertEq(oracle.QUOTE_VAULT_CONVERSION_SAMPLE(), 1, "QUOTE_VAULT_CONVERSION_SAMPLE");
        assertEq(address(oracle.BASE_FEED_1()), address(daiEthFeed), "BASE_FEED_1");
        assertEq(address(oracle.BASE_FEED_2()), address(feedZero), "BASE_FEED_2");
        assertEq(address(oracle.QUOTE_FEED_1()), address(usdcEthFeed), "QUOTE_FEED_1");
        assertEq(address(oracle.QUOTE_FEED_2()), address(feedZero), "QUOTE_FEED_2");
        assertEq(oracle.SCALE_FACTOR(), scaleFactor, "SCALE_FACTOR");
    }

    function testDeployUsdcSDaiOracle(bytes32 salt) public {
        bytes32 initCodeHash = hashInitCode(
            type(MorphoChainlinkOracleV2).creationCode,
            abi.encode(vaultZero, 1, usdcEthFeed, feedZero, 6, sDaiVault, 1e18, daiEthFeed, feedZero, 18)
        );
        address expectedAddress = computeCreate2Address(salt, initCodeHash, address(factory));

        assertFalse(factory.isMorphoChainlinkOracleV2(expectedAddress), "isChainlinkOracle");

        // vm.expectEmit(address(factory));
        // emit IMorphoChainlinkOracleV2Factory.CreateMorphoChainlinkOracleV2(address(this), expectedAddress);
        IMorphoChainlinkOracleV2 oracle = factory.createMorphoChainlinkOracleV2(
            vaultZero, 1, usdcEthFeed, feedZero, 6, sDaiVault, 1e18, daiEthFeed, feedZero, 18, salt
        );

        assertEq(expectedAddress, address(oracle), "computeCreate2Address");

        assertTrue(factory.isMorphoChainlinkOracleV2(address(oracle)), "isChainlinkOracle");

        uint256 scaleFactor = 10 ** (36 + 18 + 18 + 0 - 6 - 18 - 0) * 1e18;

        assertEq(address(oracle.BASE_VAULT()), address(vaultZero), "BASE_VAULT");
        assertEq(oracle.BASE_VAULT_CONVERSION_SAMPLE(), 1, "BASE_VAULT_CONVERSION_SAMPLE");
        assertEq(address(oracle.QUOTE_VAULT()), address(sDaiVault), "QUOTE_VAULT");
        assertEq(oracle.QUOTE_VAULT_CONVERSION_SAMPLE(), 1e18, "QUOTE_VAULT_CONVERSION_SAMPLE");
        assertEq(address(oracle.BASE_FEED_1()), address(usdcEthFeed), "BASE_FEED_1");
        assertEq(address(oracle.BASE_FEED_2()), address(feedZero), "BASE_FEED_2");
        assertEq(address(oracle.QUOTE_FEED_1()), address(daiEthFeed), "QUOTE_FEED_1");
        assertEq(address(oracle.QUOTE_FEED_2()), address(feedZero), "QUOTE_FEED_2");
        assertEq(oracle.SCALE_FACTOR(), scaleFactor, "SCALE_FACTOR");
    }
}
