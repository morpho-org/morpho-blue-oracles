// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;

interface IERC4626 {
    function convertToAssets(uint256) external view returns (uint256);
}
