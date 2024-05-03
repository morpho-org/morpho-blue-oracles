// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.19;

import {IRenzoRestakeManager} from "../interfaces/Renzo/IRenzoRestakeManager.sol";
import {IRenzoOracle} from "../interfaces/Renzo/IRenzoOracle.sol";
import {IERC20} from "../interfaces/IERC20.sol";
import {MinimalAggregatorV3Interface} from "../wsteth-exchange-rate-adapter/interfaces/MinimalAggregatorV3Interface.sol";
import {CappedRatioAdapter} from "./CappedRatioAdapter.sol";

/// @title EzEthToEthExchangeRateChainlinkAdapter
/// @author Morpho Labs
/// @custom:contact security@morpho.org
/// @notice ezETH/ETH exchange rate price feed.
/// @dev This contract should only be deployed on Ethereum and used as a price feed for Morpho oracles.
contract EzEthToEthExchangeRateChainlinkAdapter is CappedRatioAdapter, MinimalAggregatorV3Interface {
    /// @inheritdoc MinimalAggregatorV3Interface
    // @dev The calculated price has 18 decimals precision, whatever the value of `decimals`.
    uint8 public override constant decimals = 18;

    /// @notice The description of the price feed.
    string public constant description = "ezETH/ETH exchange rate";

    /// @notice The address of the Renzo restake manager in Ethereum.
    IRenzoRestakeManager public constant RENZO_RESTAKE_MANAGER = IRenzoRestakeManager(0x74a09653A083691711cF8215a6ab074BB4e99ef5);

    /// @notice The address of the Renzo ezETH token in Ethereum
    IERC20 public constant EZ_ETH = IERC20(0xbf5495Efe5DB9ce00f80364C8B423567e58d2110);

    constructor() CappedRatioAdapter(
        875,   // maxYearlyRatioGrowthPct
        7 days // minSnapshotGap
    ) {
        takeSnapshot();
    }

    /// @inheritdoc MinimalAggregatorV3Interface
    /// @dev Returns zero for roundId, startedAt, updatedAt and answeredInRound.
    /// @dev Silently overflows if `amountForShare`'s return value is greater than `type(int256).max`.
    function latestRoundData() external override view returns (uint80, int256, uint256, uint256, uint80) {
        return (0, int256(getCappedRatio()), 0, 0, 0);
    }

    /// @inheritdoc CappedRatioAdapter
    function getRatio() public override view returns (uint256) {
        (,, uint256 _currentValueInProtocol) = RENZO_RESTAKE_MANAGER.calculateTVLs();

        // This is just returning the percentage of TVL that matches the percentage of ezETH being burned
        // baseAsset is safely assumed to be the ezETH ERC20
        uint256 totalSupply = EZ_ETH.totalSupply();
        return IRenzoOracle(RENZO_RESTAKE_MANAGER.renzoOracle()).calculateRedeemAmount(
            1 ether,
            totalSupply,
            _currentValueInProtocol
        );
    }
}
