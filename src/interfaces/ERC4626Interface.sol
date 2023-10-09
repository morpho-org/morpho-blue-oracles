// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

interface ERC4626Interface {
    function convertToAssets(uint256) external view returns (uint256);
    function decimals() external view returns (uint256);
}
