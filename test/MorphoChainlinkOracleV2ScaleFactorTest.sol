// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "../lib/forge-std/src/Test.sol";
import "../src/morpho-chainlink/MorphoChainlinkOracleV2.sol";
import "../src/morpho-chainlink/interfaces/IERC4626.sol";
import "./helpers/Constants.sol";

contract MorphoChainlinkOracleV2ScaleFactorTest is Test {
    function testConstructorScaleFactorZero() public {
        vm.expectRevert(bytes(ErrorsLib.SCALE_FACTOR_IS_ZERO));
        new MorphoChainlinkOracleV2(
            IERC4626(address(1)), 2, feedZero, feedZero, 36, vaultZero, 1, feedZero, feedZero, 0
        );
    }
}
