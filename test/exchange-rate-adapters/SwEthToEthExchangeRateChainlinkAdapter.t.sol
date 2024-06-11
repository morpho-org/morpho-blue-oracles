// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.19;

import {vaultZero, feedZero} from "../helpers/Constants.sol";
import {Test} from "../../lib/forge-std/src/Test.sol";
import {MorphoChainlinkOracleV2} from "../../src/morpho-chainlink/MorphoChainlinkOracleV2.sol";
import {SwEthToEthExchangeRateChainlinkAdapter} from
    "../../src/exchange-rate-adapters/SwEthToEthExchangeRateChainlinkAdapter.sol";
import {AggregatorV3Interface} from "../../src/morpho-chainlink/interfaces/AggregatorV3Interface.sol";
import {ISwETH} from "../../src/interfaces/swell/ISwETH.sol";

contract SwEthToEthExchangeRateChainlinkAdapterTest is Test {
    ISwETH public constant SWETH = ISwETH(0xf951E335afb289353dc249e82926178EaC7DEd78);

    SwEthToEthExchangeRateChainlinkAdapter internal adapter;
    MorphoChainlinkOracleV2 internal morphoOracle;

    function setUp() public {
        vm.createSelectFork(vm.envString("ETH_RPC_URL"), 20066000);
        require(block.chainid == 1, "chain isn't Ethereum");
        adapter = new SwEthToEthExchangeRateChainlinkAdapter();
        morphoOracle = new MorphoChainlinkOracleV2(
            vaultZero, 1, AggregatorV3Interface(address(adapter)), feedZero, 18, vaultZero, 1, feedZero, feedZero, 18
        );
    }

    function test_decimals() public {
        assertEq(adapter.decimals(), uint8(18));
    }

    function test_description() public {
        assertEq(adapter.description(), "swETH/ETH exchange rate");
    }

    function test_latestRoundData() public {
        (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound) =
            adapter.latestRoundData();
        assertEq(roundId, 0);
        assertEq(uint256(answer), SWETH.swETHToETHRate());
        assertEq(uint256(answer), 1.061942797958435491e18); // Exchange rate queried at block 20066000
        assertEq(startedAt, 0);
        assertEq(updatedAt, 0);
        assertEq(answeredInRound, 0);
    }

    function test_oracleSwEthToEthExchangeRate() public {
        (, int256 expectedPrice,,,) = adapter.latestRoundData();
        assertEq(morphoOracle.price(), uint256(expectedPrice) * 10 ** (36 + 18 - 18 - 18));
    }
}
