// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.21;

import {PendleSparkLinearDiscountOracle} from "pendle-core-v2-public/oracles/PendleSparkLinearDiscountOracle.sol";

interface IPendleSparkLinearDiscountOracleFactory {
    /// @notice Emitted when a new Pendle Spark Linear Discount Oracle is created
    /// @param caller The caller of the function
    /// @param oracle The address of the Pendle Spark Linear Discount Oracle
    event CreatePendleSparkLinearDiscountOracle(
        address indexed caller,
        address indexed oracle
    );

    /// @notice Whether an oracle was created with this factory
    function isPendleSparkLinearDiscountOracle(
        address target
    ) external view returns (bool);

    /// @notice Creates a new Pendle Spark Linear Discount Oracle
    /// @param _pt The PT Token address
    /// @param _baseDiscountPerYear The base discount per year, 100% = 1e18
    /// @param salt The salt to use for CREATE2 deployment
    function createPendleSparkLinearDiscountOracle(
        address _pt,
        uint256 _baseDiscountPerYear,
        bytes32 salt
    ) external returns (PendleSparkLinearDiscountOracle oracle);
}
