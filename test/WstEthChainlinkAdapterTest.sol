// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "../src/libraries/ErrorsLib.sol";

import "../lib/forge-std/src/Test.sol";
import "../src/adapters/WstEthChainlinkAdapter.sol";

contract WstEthChainlinkAdapterTest is Test {
    IStEth internal constant ST_ETH = IStEth(0xae7ab96520DE3A18E5e111B5EaAb095312D7fE84);

    WstEthChainlinkAdapter internal oracle;

    function setUp() public {
        vm.createSelectFork(vm.envString("ETH_RPC_URL"));
        oracle = new WstEthChainlinkAdapter(address(ST_ETH));
    }

    function testLatestRoundDataOverflow(uint256 ethByShares) public {
        ethByShares = bound(ethByShares, uint256(type(int256).max) + 1, type(uint256).max);

        vm.mockCall(
            address(ST_ETH),
            abi.encodeWithSelector(ST_ETH.getPooledEthByShares.selector, 10 ** 18),
            abi.encode(ethByShares)
        );
        vm.expectRevert(bytes(ErrorsLib.OVERFLOW));
        oracle.latestRoundData();
    }

    function testGetRoundDataOverflow(uint256 ethByShares) public {
        ethByShares = bound(ethByShares, uint256(type(int256).max) + 1, type(uint256).max);

        vm.mockCall(
            address(ST_ETH),
            abi.encodeWithSelector(ST_ETH.getPooledEthByShares.selector, 10 ** 18),
            abi.encode(ethByShares)
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
        assertEq(oracle.description(), "wstETH/ETH exchange rate");
        assertEq(oracle.version(), 1);
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

    function testGetRoundData() public {
        (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound) =
            oracle.getRoundData(1);
        assertEq(roundId, 0);
        assertEq(uint256(answer), ST_ETH.getPooledEthByShares(10 ** 18));
        assertEq(startedAt, 0);
        assertEq(updatedAt, 0);
        assertEq(answeredInRound, 0);
    }

    function testLatestRoundDataNoOverflow(uint256 ethByShares) public {
        ethByShares = bound(ethByShares, 0, uint256(type(int256).max));

        vm.mockCall(
            address(ST_ETH),
            abi.encodeWithSelector(ST_ETH.getPooledEthByShares.selector, 10 ** 18),
            abi.encode(ethByShares)
        );

        (, int256 answer,,,) = oracle.latestRoundData();
        assertEq(uint256(answer), ethByShares);
    }

    function testGetRoundDataNoOverflow(uint256 ethByShares) public {
        ethByShares = bound(ethByShares, 0, uint256(type(int256).max));

        vm.mockCall(
            address(ST_ETH),
            abi.encodeWithSelector(ST_ETH.getPooledEthByShares.selector, 10 ** 18),
            abi.encode(ethByShares)
        );

        (, int256 answer,,,) = oracle.getRoundData(1);
        assertEq(uint256(answer), ethByShares);
    }

    function testLatestRoundDataBounds() public {
        (, int256 answer,,,) = oracle.latestRoundData();
        assertGe(uint256(answer), 1154690031824824994); // Exchange rate queried at block 19070943
        assertLe(uint256(answer), 1.5e18); // Max bounds of the exchange rate. Should work for a long enough time.
    }
}
