// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "./helpers/Constants.sol";
import "../lib/forge-std/src/Test.sol";
import {MorphoChainlinkOracleV2} from "../src/morpho-chainlink/MorphoChainlinkOracleV2.sol";
import "../src/wsteth-exchange-rate-adapter/WstEthStEthExchangeRateChainlinkAdapter.sol";

contract WstEthStEthExchangeRateChainlinkAdapterTest is Test {
    IStEth internal constant ST_ETH = IStEth(0xae7ab96520DE3A18E5e111B5EaAb095312D7fE84);

    WstEthStEthExchangeRateChainlinkAdapter internal adapter;
    MorphoChainlinkOracleV2 internal morphoOracle;

    function setUp() public {
        vm.createSelectFork(vm.envString("ETH_RPC_URL"));
        require(block.chainid == 1, "chain isn't Ethereum");
        adapter = new WstEthStEthExchangeRateChainlinkAdapter();
        morphoOracle = new MorphoChainlinkOracleV2(
            vaultZero, 1, AggregatorV3Interface(address(adapter)), feedZero, 18, vaultZero, 1, feedZero, feedZero, 18
        );
    }

    function testDecimals() public {
        assertEq(adapter.decimals(), uint8(18));
    }

    function testDescription() public {
        assertEq(adapter.description(), "wstETH/stETH exchange rate");
    }

    function testLatestRoundData() public {
        (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound) =
            adapter.latestRoundData();
        assertEq(roundId, 0);
        assertEq(uint256(answer), ST_ETH.getPooledEthByShares(1 ether));
        assertEq(startedAt, 0);
        assertEq(updatedAt, 0);
        assertEq(answeredInRound, 0);
    }

    function testLatestRoundDataBounds() public {
        (, int256 answer,,,) = adapter.latestRoundData();
        assertGe(uint256(answer), 1154690031824824994); // Exchange rate queried at block 19070943
        assertLe(uint256(answer), 1.5e18); // Max bounds of the exchange rate. Should work for a long enough time.
    }

    function testOracleWstEthStEthExchangeRate() public {
        (, int256 expectedPrice,,,) = adapter.latestRoundData();
        assertEq(morphoOracle.price(), uint256(expectedPrice) * 10 ** (36 + 18 - 18 - 18));
    }
}
