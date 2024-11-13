// IPTOracleFactory.sol
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.5.0;

import {PTOraclePriceAdapter} from "../PTOraclePriceAdapter.sol";
import {IPTOracle} from "./IPTOracle.sol";

/// @title IPTOraclePriceAdapterFactory
/// @notice Interface for PTOraclePriceAdapterFactory
interface IPTOraclePriceAdapterFactory {
    /// @notice Emitted when a new PT oracle is created
    /// @param caller The caller of the function
    /// @param oracle The address of the PT oracle
    event CreatePTOracle(address indexed caller, address indexed oracle);

    /// @notice Whether a PT oracle was created with this factory
    function isPTOracle(address target) external view returns (bool);

    /// @dev Creates a new PT Oracle with the following assumptions:
    /// - The PT Oracle interface is valid and implements expected behavior
    /// - The market address is valid and exists
    /// - The duration parameter is within acceptable bounds
    /// @param _ptOracle The PT Oracle for price fetching
    /// @param _market The Pendle market address to fetch prices for
    /// @param _duration The twap duration parameter for calculating the price
    /// @param salt The salt to use for CREATE2 deployment
    function createPTOracle(
        IPTOracle _ptOracle,
        address _market,
        uint32 _duration,
        bytes32 salt
    ) external returns (PTOraclePriceAdapter oracle);
}
