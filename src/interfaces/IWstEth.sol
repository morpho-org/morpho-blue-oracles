// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.5.0;

interface IWstEth {
    function decimals() external view returns (uint8);
    function stEthPerToken() external view returns (uint256);
}
