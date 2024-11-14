// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.21;

import {PTOraclePriceAdapter} from "./PTOraclePriceAdapter.sol";
import {IPTOracle} from "./interfaces/IPTOracle.sol";
import {IPTOraclePriceAdapterFactory} from "./interfaces/IPTOraclePriceAdapterFactory.sol";

/// @title PTOraclePriceAdapterFactory
/// @notice This contract allows creation of PTOraclePriceAdapter oracles and indexes them for verification
contract PTOraclePriceAdapterFactory is IPTOraclePriceAdapterFactory {
    /* STORAGE */
    /// @inheritdoc IPTOraclePriceAdapterFactory
    mapping(address => bool) public isPTOracle;

    /* EXTERNAL */
    /// @inheritdoc IPTOraclePriceAdapterFactory
    function createPTOraclePriceAdapter(
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
        emit CreatePTOraclePriceAdapter(msg.sender, address(oracle));
    }
}
