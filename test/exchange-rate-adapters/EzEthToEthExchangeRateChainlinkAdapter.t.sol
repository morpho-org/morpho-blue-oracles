// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.19;

import {vaultZero, feedZero} from "../helpers/Constants.sol";
import {Test} from "../../lib/forge-std/src/Test.sol";
import {MorphoChainlinkOracleV2} from "../../src/morpho-chainlink/MorphoChainlinkOracleV2.sol";
import {EzEthToEthExchangeRateChainlinkAdapter} from "../../src/exchange-rate-adapters/EzEthToEthExchangeRateChainlinkAdapter.sol";
import {IRenzoRestakeManager} from "../../src/interfaces/Renzo/IRenzoRestakeManager.sol";
import {IRenzoOracle} from "../../src/interfaces/Renzo/IRenzoOracle.sol";
import {IERC20} from "../../src/interfaces/IERC20.sol";
import {AggregatorV3Interface} from "../../src/morpho-chainlink/interfaces/AggregatorV3Interface.sol";

contract EzEthToEthExchangeRateChainlinkAdapterTest is Test {
    IRenzoRestakeManager public constant RENZO_RESTAKE_MANAGER = IRenzoRestakeManager(0x74a09653A083691711cF8215a6ab074BB4e99ef5);
    IERC20 public constant EZ_ETH = IERC20(0xbf5495Efe5DB9ce00f80364C8B423567e58d2110);

    EzEthToEthExchangeRateChainlinkAdapter internal adapter;
    MorphoChainlinkOracleV2 internal morphoOracle;

    function setUp() public {
        vm.createSelectFork(vm.envString("ETH_RPC_URL"), 20066000);
        require(block.chainid == 1, "chain isn't Ethereum");
        adapter = new EzEthToEthExchangeRateChainlinkAdapter();
        morphoOracle = new MorphoChainlinkOracleV2(
            vaultZero, 1, AggregatorV3Interface(address(adapter)), feedZero, 18, vaultZero, 1, feedZero, feedZero, 18
        );
    }

    function test_decimals() public {
        assertEq(adapter.decimals(), uint8(18));
    }

    function test_description() public {
        assertEq(adapter.description(), "ezETH/ETH exchange rate");
    }

    function expectedRate() private view returns (uint256) {
        (,, uint256 _currentValueInProtocol) = RENZO_RESTAKE_MANAGER.calculateTVLs();
        uint256 totalSupply = EZ_ETH.totalSupply();
        return IRenzoOracle(RENZO_RESTAKE_MANAGER.renzoOracle()).calculateRedeemAmount(
            1 ether,
            totalSupply,
            _currentValueInProtocol
        );
    }

    function test_latestRoundData() public {
        (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound) =
            adapter.latestRoundData();
        assertEq(roundId, 0);
        assertEq(uint256(answer), expectedRate());
        assertEq(answer, 1.011474492485111833e18);  // Exchange rate queried at block 20066000
        assertEq(startedAt, 0);
        assertEq(updatedAt, 0);
        assertEq(answeredInRound, 0);
    }

    function test_oracleEzEthToEthExchangeRate() public {
        (, int256 expectedPrice,,,) = adapter.latestRoundData();
        assertEq(morphoOracle.price(), uint256(expectedPrice) * 10 ** (36 + 18 - 18 - 18));
    }
}
