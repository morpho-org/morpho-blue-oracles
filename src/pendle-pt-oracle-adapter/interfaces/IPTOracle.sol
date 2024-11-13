// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.21;

interface IPTOracle {
    function getPtToAssetRate(
        address market,
        uint32 duration
    ) external view returns (uint256);
}
