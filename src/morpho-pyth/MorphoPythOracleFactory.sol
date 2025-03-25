// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.21;

import {IMorphoPythOracle} from "./interfaces/IMorphoPythOracle.sol";
import {IMorphoPythOracleFactory} from "./interfaces/IMorphoPythOracleFactory.sol";
import {IERC4626} from "./libraries/VaultLib.sol";

import {MorphoPythOracle} from "./MorphoPythOracle.sol";

/// @title MorphoPythOracleFactory
/// @author Pyth Data Association
/// @notice This contract allows to create MorphoPythOracle oracles, and to index them easily.
contract MorphoPythOracleFactory is IMorphoPythOracleFactory {
    /* STORAGE */

    /// @inheritdoc IMorphoPythOracleFactory
    mapping(address => bool) public isMorphoPythOracle;

    /* EXTERNAL */

    /// @inheritdoc IMorphoPythOracleFactory
    function createMorphoPythOracle(
        address pyth,
        IERC4626 baseVault,
        uint256 baseVaultConversionSample,
        bytes32 baseFeed1,
        bytes32 baseFeed2,
        uint256 baseTokenDecimals,
        IERC4626 quoteVault,
        uint256 quoteVaultConversionSample,
        bytes32 quoteFeed1,
        bytes32 quoteFeed2,
        uint256 quoteTokenDecimals,
        uint256 priceFeedMaxAge,
        bytes32 salt
    ) external returns (IMorphoPythOracle oracle) {
        oracle = new MorphoPythOracle{salt: salt}(
            pyth,
            baseVault,
            baseVaultConversionSample,
            baseFeed1,
            baseFeed2,
            baseTokenDecimals,
            quoteVault,
            quoteVaultConversionSample,
            quoteFeed1,
            quoteFeed2,
            quoteTokenDecimals,
            priceFeedMaxAge
        );

        isMorphoPythOracle[address(oracle)] = true;

        emit CreateMorphoPythOracle(msg.sender, address(oracle));
    }
}
