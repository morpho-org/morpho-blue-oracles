// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "./helpers/BaseTest.sol";

import "../src/ChainlinkOracleFactory.sol";

import {ChainlinkDataFeedLib} from "../src/libraries/ChainlinkDataFeedLib.sol";

contract ChainlinkOracleFactoryTest is BaseTest {
    using ChainlinkDataFeedLib for AggregatorV3Interface;

    ChainlinkOracleFactory factory;

    function setUp() public override {
        super.setUp();

        factory = new ChainlinkOracleFactory();
    }

    function testDeploySDaiUsdcOracle(bytes32 salt) public {
        bytes32 initCodeHash = hashInitCode(
            type(ChainlinkOracle).creationCode,
            abi.encode(sDaiVault, 1e18, vaultZero, 1, daiEthFeed, feedZero, usdcEthFeed, feedZero, 18, 6)
        );
        address expectedAddress = computeCreate2Address(salt, initCodeHash, address(factory));

        assertFalse(factory.isChainlinkOracle(expectedAddress), "isChainlinkOracle");

        // vm.expectEmit(address(factory));
        // emit ChainlinkOracleFactory.CreateChainlinkOracle(
        //     expectedAddress, address(this), address(sDaiVault), 1e18, address(vaultZero), 1, salt
        // );
        // emit ChainlinkOracleFactory.CreateChainlinkOracleFeeds(
        //     expectedAddress, address(daiEthFeed), address(feedZero), address(usdcEthFeed), address(feedZero), 8, 6
        // );
        IChainlinkOracle oracle = factory.createChainlinkOracle(
            sDaiVault, 1e18, vaultZero, 1, daiEthFeed, feedZero, usdcEthFeed, feedZero, 18, 6, salt
        );

        assertEq(expectedAddress, address(oracle), "computeCreate2Address");

        assertTrue(factory.isChainlinkOracle(address(oracle)), "isChainlinkOracle");

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
            type(ChainlinkOracle).creationCode,
            abi.encode(vaultZero, 1, sDaiVault, 1e18, usdcEthFeed, feedZero, daiEthFeed, feedZero, 6, 18)
        );
        address expectedAddress = computeCreate2Address(salt, initCodeHash, address(factory));

        assertFalse(factory.isChainlinkOracle(expectedAddress), "isChainlinkOracle");

        // vm.expectEmit(address(factory));
        // emit ChainlinkOracleFactory.CreateChainlinkOracle(
        //     expectedAddress, address(this), address(vaultZero), 1, address(sDaiVault), 1e18, salt
        // );
        // emit ChainlinkOracleFactory.CreateChainlinkOracleFeeds(
        //     expectedAddress, address(usdcEthFeed), address(feedZero), address(daiEthFeed), address(feedZero), 6, 18
        // );
        IChainlinkOracle oracle = factory.createChainlinkOracle(
            vaultZero, 1, sDaiVault, 1e18, usdcEthFeed, feedZero, daiEthFeed, feedZero, 6, 18, salt
        );

        assertEq(expectedAddress, address(oracle), "computeCreate2Address");

        assertTrue(factory.isChainlinkOracle(address(oracle)), "isChainlinkOracle");

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
