// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.21;

import {IWstEth} from "./interfaces/IWstEth.sol";
import {MinimalAggregatorV3Interface} from "./interfaces/MinimalAggregatorV3Interface.sol";

import {ErrorsLib} from "./libraries/ErrorsLib.sol";

/// @title WstEthEthExchangeRateChainlinkAdapter
/// @author Morpho Labs
/// @custom:contact security@morpho.org
/// @notice wstETH/ETH exchange rate price feed.
/// @dev This contract should only be used as price feed for `ChainlinkOracle`.
contract WstEthEthExchangeRateChainlinkAdapter is MinimalAggregatorV3Interface {
    uint8 public constant decimals = 18;
    string public constant description = "wstETH/ETH exchange rate";

    IWstEth public immutable WST_ETH;

    constructor(address wstEth) {
        require(wstEth != address(0), ErrorsLib.ZERO_ADDRESS);

        WST_ETH = IWstEth(wstEth);
    }

    function latestRoundData() external view returns (uint80, int256, uint256, uint256, uint80) {
        // It is assumed that `stEthPerToken` returns a price with 18 decimals precision.
        return (0, int256(WST_ETH.stEthPerToken()), 0, 0, 0);
    }
}