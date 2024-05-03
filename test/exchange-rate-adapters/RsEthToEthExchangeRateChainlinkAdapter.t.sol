// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.19;

import {vaultZero, feedZero} from "../helpers/Constants.sol";
import {Test} from "../../lib/forge-std/src/Test.sol";
import {MorphoChainlinkOracleV2} from "../../src/morpho-chainlink/MorphoChainlinkOracleV2.sol";
import {RsEthToEthExchangeRateChainlinkAdapter} from "../../src/exchange-rate-adapters/RsEthToEthExchangeRateChainlinkAdapter.sol";
import {AggregatorV3Interface} from "../../src/morpho-chainlink/interfaces/AggregatorV3Interface.sol";
import {IKelpLRTConfig} from "../../src/interfaces/kelp/IKelpLRTConfig.sol";
import {IKelpLRTOracle} from "../../src/interfaces/kelp/IKelpLRTOracle.sol";

contract RsEthToEthExchangeRateChainlinkAdapterTest is Test {
    IKelpLRTConfig public constant KELP_LRT_CONFIG = IKelpLRTConfig(0x947Cb49334e6571ccBFEF1f1f1178d8469D65ec7);
    bytes32 public constant LRT_ORACLE = keccak256("LRT_ORACLE");

    RsEthToEthExchangeRateChainlinkAdapter internal adapter;
    MorphoChainlinkOracleV2 internal morphoOracle;

    function setUp() public {
        vm.createSelectFork(vm.envString("ETH_RPC_URL"), 20066000);
        require(block.chainid == 1, "chain isn't Ethereum");
        adapter = new RsEthToEthExchangeRateChainlinkAdapter();
        morphoOracle = new MorphoChainlinkOracleV2(
            vaultZero, 1, AggregatorV3Interface(address(adapter)), feedZero, 18, vaultZero, 1, feedZero, feedZero, 18
        );
    }

    function test_decimals() public {
        assertEq(adapter.decimals(), uint8(18));
    }

    function test_description() public {
        assertEq(adapter.description(), "rsETH/ETH exchange rate");
    }
    
    function test_latestRoundData() public {
        IKelpLRTOracle lrtOracle = IKelpLRTOracle(KELP_LRT_CONFIG.getContract(LRT_ORACLE));
        uint256 expectedRate = lrtOracle.rsETHPrice();

        (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound) =
            adapter.latestRoundData();
        assertEq(roundId, 0);
        assertEq(uint256(answer), expectedRate);
        assertEq(uint256(answer), 1.014115456823606415e18);  // Exchange rate queried at block 20066000
        assertEq(startedAt, 0);
        assertEq(updatedAt, 0);
        assertEq(answeredInRound, 0);
    }

    function test_oracleRsEthToEthExchangeRate() public {
        (, int256 expectedPrice,,,) = adapter.latestRoundData();
        assertEq(morphoOracle.price(), uint256(expectedPrice) * 10 ** (36 + 18 - 18 - 18));
    }
}
