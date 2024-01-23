// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.21;

import {IStETH} from "../interfaces/IStETH.sol";
import {AggregatorV3Interface} from "../interfaces/AggregatorV3Interface.sol";

/// @title WstEthOracle
/// @author Morpho Labs
/// @custom:contact security@morpho.org
/// @notice wstETH/ETH exchange rate price feed.
contract WstEthOracle is AggregatorV3Interface {
    uint256 public constant version = 1;
    uint8 public constant DECIMALS = uint8(18);
    string public constant description = "wstETH/ETH exchange rate price";

    IStETH public immutable ST_ETH;

    constructor(address stEth) {
        require(stEth != address(0), "WstEthOracle: ZERO_ADDRESS");
        ST_ETH = IStETH(stEth);
    }

    function decimals() external view returns (uint8) {
        return DECIMALS;
    }

    function getRoundData(uint80)
        external
        view
        returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound)
    {
        return latestRoundData();
    }

    function latestRoundData()
        public
        view
        returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound)
    {
        uint256 ethByShares = ST_ETH.getPooledEthByShares(10 ** DECIMALS);
        require(ethByShares < type(uint256).max, "WstEthOracle: OVERFLOW");
        answer = int256(ethByShares);
    }
}
