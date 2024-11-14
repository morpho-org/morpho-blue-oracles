// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.21;

import {PendleSparkLinearDiscountOracle} from "pendle-core-v2-public/oracles/PendleSparkLinearDiscountOracle.sol";
import {IPendleSparkLinearDiscountOracleFactory} from "./interfaces/IPendleSparkLinearDiscountOracleFactory.sol";

contract PendleSparkLinearDiscountOracleFactory is
    IPendleSparkLinearDiscountOracleFactory
{
    mapping(address => bool) public isPendleSparkLinearDiscountOracle;

    function createPendleSparkLinearDiscountOracle(
        address _pt,
        uint256 _baseDiscountPerYear,
        bytes32 salt
    ) external returns (PendleSparkLinearDiscountOracle oracle) {
        oracle = new PendleSparkLinearDiscountOracle{salt: salt}(
            _pt,
            _baseDiscountPerYear
        );

        isPendleSparkLinearDiscountOracle[address(oracle)] = true;
        emit CreatePendleSparkLinearDiscountOracle(msg.sender, address(oracle));
    }
}
