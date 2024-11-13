// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.21;

import {PTOraclePriceAdapter} from "./PTOraclePriceAdapter.sol";
import {IPTOracle} from "./interfaces/IPTOracle.sol";
import {IPTOraclePriceAdapterFactory} from "./interfaces/IPTOraclePriceAdapterFactory.sol";

/// @title PTOracleFactory
/// @notice This contract allows creation of PT Oracles and indexes them for verification
contract PTOraclePriceAdapterFactory is IPTOraclePriceAdapterFactory {
    /* STORAGE */
    /// @inheritdoc IPTOraclePriceAdapterFactory
    mapping(address => bool) public isPTOracle;

    /* EXTERNAL */
    /// @inheritdoc IPTOraclePriceAdapterFactory
    function createPTOracle(
        IPTOracle _ptOracle,
        address _market,
        uint32 _duration,
        bytes32 salt
    ) external returns (PTOraclePriceAdapter oracle) {
        oracle = new PTOraclePriceAdapter{salt: salt}(
            _ptOracle,
            _market,
            _duration
        );

        isPTOracle[address(oracle)] = true;
        emit CreatePTOracle(msg.sender, address(oracle));
    }
}
