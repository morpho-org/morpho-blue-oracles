// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.21;

import {IStEth} from "../interfaces/IStEth.sol";
import {MinimalAggregatorV3Interface} from "../interfaces/MinimalAggregatorV3Interface.sol";

import {ErrorsLib} from "../libraries/ErrorsLib.sol";

/// @title WstEthEthExchangeRateChainlinkAdapter
/// @author Morpho Labs
/// @custom:contact security@morpho.org
/// @notice wstETH/ETH exchange rate price feed.
/// @dev This contract should only be used as price feed for `ChainlinkOracle`.
contract WstEthEthExchangeRateChainlinkAdapter is MinimalAggregatorV3Interface {
    uint8 public constant decimals = 18;

    IStEth public immutable ST_ETH;

    constructor(address stEth) {
        require(stEth != address(0), ErrorsLib.ZERO_ADDRESS);
        ST_ETH = IStEth(stEth);
    }

    function latestRoundData() external view returns (uint80, int256, uint256, uint256, uint80) {
        uint256 answer = ST_ETH.getPooledEthByShares(10 ** decimals);
        return (0, int256(answer), 0, 0, 0);
    }
}
