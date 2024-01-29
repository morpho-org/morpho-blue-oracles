// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "../src/libraries/ErrorsLib.sol";

import "../lib/forge-std/src/Test.sol";
import "../src/adapters/WstEthChainlinkAdapter.sol";

contract ChainlinkOracleTest is Test {
    IStEth internal constant ST_ETH = IStEth(0xae7ab96520DE3A18E5e111B5EaAb095312D7fE84);

    WstEthChainlinkAdapter internal oracle;

    function setUp() public {
        vm.createSelectFork(vm.envString("ETH_RPC_URL"));
        oracle = new WstEthChainlinkAdapter(address(ST_ETH));
    }

    function testLastRoundDataUintMax() public {
        vm.mockCall(
            address(ST_ETH),
            abi.encodeWithSelector(ST_ETH.getPooledEthByShares.selector, 10 ** 18),
            abi.encode(type(uint256).max)
        );
        vm.expectRevert(bytes(ErrorsLib.OVERFLOW));
        oracle.latestRoundData();
    }

    function testGetRoundDataUintMax() public {
        vm.mockCall(
            address(ST_ETH),
            abi.encodeWithSelector(ST_ETH.getPooledEthByShares.selector, 10 ** 18),
            abi.encode(type(uint256).max)
        );
        vm.expectRevert(bytes(ErrorsLib.OVERFLOW));
        oracle.getRoundData(1);
    }

    function testDecimals() public {
        assertEq(oracle.decimals(), uint8(18));
    }

    function testDeployZeroAddress() public {
        vm.expectRevert(bytes(ErrorsLib.ZERO_ADDRESS));
        new WstEthChainlinkAdapter(address(0));
    }

    function testConfig() public {
        assertEq(oracle.description(), "wstETH/ETH exchange rate price");
        assertEq(oracle.version(), 1);
    }

    function testLastRoundData() public {
        (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound) =
            oracle.latestRoundData();
        assertEq(roundId, 0);
        assertEq(uint256(answer), ST_ETH.getPooledEthByShares(10 ** 18));
        assertEq(startedAt, 0);
        assertEq(updatedAt, 0);
        assertEq(answeredInRound, 0);
    }

    function testGetLastRoundData() public {
        (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound) =
            oracle.getRoundData(1);
        assertEq(roundId, 0);
        assertEq(uint256(answer), ST_ETH.getPooledEthByShares(10 ** 18));
        assertEq(startedAt, 0);
        assertEq(updatedAt, 0);
        assertEq(answeredInRound, 0);
    }

    function testLastRoundDataBounds() public {
        (, int256 answer,,,) = oracle.latestRoundData();
        assertGe(uint256(answer), 1154690031824824994); // Exchange rate queried at block 19070943
        assertLe(uint256(answer), 1.5e18); // Max bounds of the exchange rate. Should work for a long enough time.
    }
}
