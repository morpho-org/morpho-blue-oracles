// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "./ChainlinkOracleTest.sol";

import "../src/ChainlinkOracleFactory.sol";

import {ChainlinkDataFeedLib} from "../src/libraries/ChainlinkDataFeedLib.sol";

contract ChainlinkOracleFactoryTest is ChainlinkOracleTest {
    using ChainlinkDataFeedLib for AggregatorV3Interface;

    ChainlinkOracleFactory factory;

    function setUp() public override {
        super.setUp();

        factory = new ChainlinkOracleFactory();
    }

    function testDeployOracleWbtcUsdc(bytes32 salt) public {
        bytes32 initCodeHash = hashInitCode(
            type(ChainlinkOracle).creationCode,
            abi.encode(vaultZero, wBtcBtcFeed, btcUsdFeed, usdcUsdFeed, feedZero, 1, 8, 6)
        );
        address expectedAddress = computeCreate2Address(salt, initCodeHash, address(factory));

        assertFalse(factory.isChainlinkOracle(expectedAddress), "isChainlinkOracle");

        vm.expectEmit(address(factory));
        emit ChainlinkOracleFactory.CreateChainlinkOracle(
            expectedAddress, address(this), vaultZero, wBtcBtcFeed, btcUsdFeed, usdcUsdFeed, feedZero, 1, 8, 6, salt
        );
        IChainlinkOracle oracle =
            factory.createChainlinkOracle(vaultZero, wBtcBtcFeed, btcUsdFeed, usdcUsdFeed, feedZero, 1, 8, 6, salt);

        assertEq(expectedAddress, address(oracle), "computeCreate2Address");

        assertTrue(factory.isChainlinkOracle(address(oracle)), "isChainlinkOracle");

        uint256 expectedScaleFactor = 10
            ** (
                36 + 6 + usdcUsdFeed.getDecimals() + feedZero.getDecimals() - 8 - wBtcBtcFeed.getDecimals()
                    - btcUsdFeed.getDecimals()
            ) / 1;

        assertEq(address(oracle.VAULT()), address(vaultZero), "VAULT");
        assertEq(oracle.VAULT_CONVERSION_SAMPLE(), 1, "VAULT_CONVERSION_SAMPLE");
        assertEq(address(oracle.BASE_FEED_1()), address(wBtcBtcFeed), "BASE_FEED_1");
        assertEq(address(oracle.BASE_FEED_2()), address(btcUsdFeed), "BASE_FEED_2");
        assertEq(address(oracle.QUOTE_FEED_1()), address(usdcUsdFeed), "QUOTE_FEED_1");
        assertEq(address(oracle.QUOTE_FEED_2()), address(feedZero), "QUOTE_FEED_2");
        assertEq(oracle.SCALE_FACTOR(), expectedScaleFactor, "SCALE_FACTOR");
    }

    function testDeployOracleUsdcWbtc(bytes32 salt) public {
        bytes32 initCodeHash = hashInitCode(
            type(ChainlinkOracle).creationCode,
            abi.encode(vaultZero, usdcUsdFeed, feedZero, wBtcBtcFeed, btcUsdFeed, 1, 6, 8)
        );
        address expectedAddress = computeCreate2Address(salt, initCodeHash, address(factory));

        assertFalse(factory.isChainlinkOracle(expectedAddress), "isChainlinkOracle");

        vm.expectEmit(address(factory));
        emit ChainlinkOracleFactory.CreateChainlinkOracle(
            expectedAddress, address(this), vaultZero, usdcUsdFeed, feedZero, wBtcBtcFeed, btcUsdFeed, 1, 6, 8, salt
        );
        IChainlinkOracle oracle =
            factory.createChainlinkOracle(vaultZero, usdcUsdFeed, feedZero, wBtcBtcFeed, btcUsdFeed, 1, 6, 8, salt);

        assertEq(expectedAddress, address(oracle), "computeCreate2Address");

        assertTrue(factory.isChainlinkOracle(address(oracle)), "isChainlinkOracle");

        uint256 expectedScaleFactor = 10
            ** (
                36 + 8 + wBtcBtcFeed.getDecimals() + btcUsdFeed.getDecimals() - 6 - usdcUsdFeed.getDecimals()
                    - feedZero.getDecimals()
            ) / 1;

        assertEq(address(oracle.VAULT()), address(vaultZero), "VAULT");
        assertEq(oracle.VAULT_CONVERSION_SAMPLE(), 1, "VAULT_CONVERSION_SAMPLE");
        assertEq(address(oracle.BASE_FEED_1()), address(usdcUsdFeed), "BASE_FEED_1");
        assertEq(address(oracle.BASE_FEED_2()), address(feedZero), "BASE_FEED_2");
        assertEq(address(oracle.QUOTE_FEED_1()), address(wBtcBtcFeed), "QUOTE_FEED_1");
        assertEq(address(oracle.QUOTE_FEED_2()), address(btcUsdFeed), "QUOTE_FEED_2");
        assertEq(oracle.SCALE_FACTOR(), expectedScaleFactor, "SCALE_FACTOR");
    }
}
