// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.5.0;

interface IWeEth {
    // Amount of weETH for 1 eETH
    function getRate() external view returns (uint256);
}
