// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

contract ChainlinkAggregatorMock {
    int256 public answer;

    function setAnwser(int256 newAnswer) external {
        answer = newAnswer;
    }

    function latestRoundData() external view returns (uint80, int256, uint256, uint256, uint80) {
        return (0, answer, 0, 0, 0);
    }

    function decimals() external pure returns (uint256) {
        return 8;
    }
}
