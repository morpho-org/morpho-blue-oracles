// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "../src/libraries/ErrorsLib.sol";

import "../lib/forge-std/src/Test.sol";
import "../src/adapters/WstEthEthExchangeRateChainlinkAdapter.sol";
import "../src/ChainlinkOracle.sol";
import "./helpers/Constants.sol";

contract WstEthEthExchangeRateChainlinkAdapterTest is Test {
    IStEth internal constant ST_ETH = IStEth(0xae7ab96520DE3A18E5e111B5EaAb095312D7fE84);

    WstEthEthExchangeRateChainlinkAdapter internal oracle;
    ChainlinkOracle internal chainlinkOracle;

    function setUp() public {
        vm.createSelectFork(vm.envString("ETH_RPC_URL"));
        oracle = new WstEthEthExchangeRateChainlinkAdapter(address(ST_ETH));
        chainlinkOracle = new ChainlinkOracle(vaultZero, oracle, feedZero, feedZero, feedZero, 1, 18, 18);
    }

    function testDecimals() public {
        assertEq(oracle.decimals(), uint8(18));
    }

    function testDescription() public {
        assertEq(oracle.description(), "wstETH/ETH exchange rate");
    }

    function testDeployZeroAddress() public {
        vm.expectRevert(bytes(ErrorsLib.ZERO_ADDRESS));
        new WstEthEthExchangeRateChainlinkAdapter(address(0));
    }

    function testReverts() public {
        vm.expectRevert();
        oracle.version();

        vm.expectRevert();
        oracle.getRoundData(0);
    }

    function testLatestRoundData() public {
        (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound) =
            oracle.latestRoundData();
        assertEq(roundId, 0);
        assertEq(uint256(answer), ST_ETH.getPooledEthByShares(10 ** 18));
        assertEq(startedAt, 0);
        assertEq(updatedAt, 0);
        assertEq(answeredInRound, 0);
    }

    function testLatestRoundDataBounds() public {
        (, int256 answer,,,) = oracle.latestRoundData();
        assertGe(uint256(answer), 1154690031824824994); // Exchange rate queried at block 19070943
        assertLe(uint256(answer), 1.5e18); // Max bounds of the exchange rate. Should work for a long enough time.
    }

    function testOracleWstEthEthExchangeRate() public {
        (, int256 expectedPrice,,,) = oracle.latestRoundData();
        assertEq(chainlinkOracle.price(), uint256(expectedPrice) * 10 ** (36 + 18 - 18 - 18));
    }
}
