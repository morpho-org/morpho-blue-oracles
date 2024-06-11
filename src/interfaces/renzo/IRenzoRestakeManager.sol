// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.5.0;

interface IRenzoRestakeManager {
    function calculateTVLs() external view returns (uint256[][] memory, uint256[] memory, uint256);
    function renzoOracle() external view returns (address);
}
