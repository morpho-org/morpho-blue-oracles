// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

interface IERC4626 {
    function convertToAssets(uint256) external view returns (uint256);
    function decimals() external view returns (uint256);
}
