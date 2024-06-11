// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.19;

import {vaultZero, feedZero} from "../helpers/Constants.sol";
import {Test} from "../../lib/forge-std/src/Test.sol";
import {MorphoChainlinkOracleV2} from "../../src/morpho-chainlink/MorphoChainlinkOracleV2.sol";
import {RswEthToEthExchangeRateChainlinkAdapter} from
    "../../src/exchange-rate-adapters/RswEthToEthExchangeRateChainlinkAdapter.sol";
import {AggregatorV3Interface} from "../../src/morpho-chainlink/interfaces/AggregatorV3Interface.sol";
import {IRswETH} from "../../src/interfaces/swell/IRswETH.sol";

contract RswEthToEthExchangeRateChainlinkAdapterTest is Test {
    IRswETH public constant RSWETH = IRswETH(0xFAe103DC9cf190eD75350761e95403b7b8aFa6c0);

    RswEthToEthExchangeRateChainlinkAdapter internal adapter;
    MorphoChainlinkOracleV2 internal morphoOracle;

    function setUp() public {
        vm.createSelectFork(vm.envString("ETH_RPC_URL"), 20066000);
        require(block.chainid == 1, "chain isn't Ethereum");
        adapter = new RswEthToEthExchangeRateChainlinkAdapter();
        morphoOracle = new MorphoChainlinkOracleV2(
            vaultZero, 1, AggregatorV3Interface(address(adapter)), feedZero, 18, vaultZero, 1, feedZero, feedZero, 18
        );
    }

    function test_decimals() public {
        assertEq(adapter.decimals(), uint8(18));
    }

    function test_description() public {
        assertEq(adapter.description(), "rswETH/ETH exchange rate");
    }

    function test_latestRoundData() public {
        (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound) =
            adapter.latestRoundData();
        assertEq(roundId, 0);
        assertEq(uint256(answer), RSWETH.rswETHToETHRate());
        assertEq(uint256(answer), 1.010001498638344043e18); // Exchange rate queried at block 20066000
        assertEq(startedAt, 0);
        assertEq(updatedAt, 0);
        assertEq(answeredInRound, 0);
    }

    function test_oracleSwEthToEthExchangeRate() public {
        (, int256 expectedPrice,,,) = adapter.latestRoundData();
        assertEq(morphoOracle.price(), uint256(expectedPrice) * 10 ** (36 + 18 - 18 - 18));
    }
}
