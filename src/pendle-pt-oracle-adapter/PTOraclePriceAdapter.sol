// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.21;

import {IPTOracle} from "./interfaces/IPTOracle.sol";
import {MinimalAggregatorV3Interface} from "./interfaces/MinimalAggregatorV3Interface.sol";

contract PTOraclePriceAdapter is MinimalAggregatorV3Interface {
    IPTOracle public oracle;
    address public market;
    uint32 public duration;

    constructor(IPTOracle _oracle, address _market, uint32 _duration) {
        oracle = _oracle;
        market = _market;
        duration = _duration;
    }

    function decimals() external view returns (uint8) {
        return 18;
    }

    function latestRoundData()
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        )
    {
        return (0, int256(oracle.getPtToAssetRate(market, duration)), 0, 0, 0);
    }
}
