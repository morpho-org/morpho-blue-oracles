// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;

interface IStEth {
    function getPooledEthByShares(uint256) external view returns (uint256);
}
