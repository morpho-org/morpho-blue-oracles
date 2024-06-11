// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.5.0;

interface IKelpLRTOracle {
    function rsETHPrice() external view returns (uint256);
}
