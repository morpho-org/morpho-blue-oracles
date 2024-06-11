// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.5.0;

interface IRenzoOracle {
    function calculateRedeemAmount(
        uint256 _ezETHBeingBurned,
        uint256 _existingEzETHSupply,
        uint256 _currentValueInProtocol
    ) external pure returns (uint256);
}
