// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.5.0;

import {IERC4626} from "../libraries/VaultLib.sol";
import {IMorphoPythOracle} from "./IMorphoPythOracle.sol";

/// @title IMorphoPythOracleFactory
/// @author Morpho Labs
/// @notice Interface for MorphoPythOracleFactory
interface IMorphoPythOracleFactory {
    /// @notice Emitted when a new Pyth oracle is created.
    /// @param oracle The address of the Pyth oracle.
    /// @param caller The caller of the function.
    event CreateMorphoPythOracle(address caller, address oracle);

    /// @notice Whether a Pyth oracle vault was created with the factory.
    function isMorphoPythOracle(address target) external view returns (bool);

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
    ) external returns (IMorphoPythOracle oracle);
}
