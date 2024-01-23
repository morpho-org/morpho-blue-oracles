// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.21;

import {IStEth} from "../interfaces/IStEth.sol";
import {AggregatorV3Interface} from "../interfaces/AggregatorV3Interface.sol";

/// @title WstEthOracle
/// @author Morpho Labs
/// @custom:contact security@morpho.org
/// @notice wstETH/ETH exchange rate price feed.
/// @dev This contract should only be used as price feed for `ChainlinkOracle`.
contract WstEthOracle is AggregatorV3Interface {
    uint8 public constant decimals = uint8(18);
    string public constant description = "wstETH/ETH exchange rate price";
    uint256 public constant version = 1;

    IStEth public immutable ST_ETH;

    constructor(address stEth) {
        require(stEth != address(0), "WstEthOracle: ZERO_ADDRESS");
        ST_ETH = IStEth(stEth);
    }

    function getRoundData(uint80) external view returns (uint80, int256, uint256, uint256, uint80) {
        return latestRoundData();
    }

    function latestRoundData() public view returns (uint80, int256, uint256, uint256, uint80) {
        uint256 ethByShares = ST_ETH.getPooledEthByShares(10 ** decimals);
        require(ethByShares < type(uint256).max, "WstEthOracle: OVERFLOW");
        return (0, int256(ethByShares), 0, 0, 0);
    }
}
