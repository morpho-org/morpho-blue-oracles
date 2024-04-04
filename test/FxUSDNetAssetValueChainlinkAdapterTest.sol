// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "./helpers/Constants.sol";
import "../lib/forge-std/src/Test.sol";
import {MorphoChainlinkOracleV2} from "../src/morpho-chainlink/MorphoChainlinkOracleV2.sol";
import "../src/fxusd-nav-adapter/FxUSDNetAssetValueChainlinkAdapter.sol";

contract FxUSDNetAssetValueChainlinkAdapterTest is Test {
    IFxUSD internal constant fxUSD = IFxUSD(0x085780639CC2cACd35E474e71f4d000e2405d8f6);

    FxUSDNetAssetValueChainlinkAdapter internal adapter;
    MorphoChainlinkOracleV2 internal morphoOracle;

    function setUp() public {
        vm.createSelectFork(vm.envString("ETH_RPC_URL"));
        require(block.chainid == 1, "chain isn't Ethereum");
        adapter = new FxUSDNetAssetValueChainlinkAdapter(fxUSD);
        morphoOracle = new MorphoChainlinkOracleV2(
            vaultZero, 1, AggregatorV3Interface(address(adapter)), feedZero, 18, vaultZero, 1, feedZero, feedZero, 18
        );
    }

    function testDecimals() public {
        assertEq(adapter.decimals(), uint8(18));
    }

    function testDescription() public {
        assertEq(adapter.description(), "fxUSD net asset value");
    }

    function testLatestRoundData() public {
        (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound) =
            adapter.latestRoundData();
        assertEq(roundId, 0);
        assertEq(uint256(answer), fxUSD.nav());
        assertEq(startedAt, 0);
        assertEq(updatedAt, 0);
        assertEq(answeredInRound, 0);
    }

    function testOracleFxUSDNav() public {
        (, int256 expectedPrice,,,) = adapter.latestRoundData();
        assertEq(morphoOracle.price(), uint256(expectedPrice) * 10 ** (36 + 18 - 18 - 18));
    }
}
