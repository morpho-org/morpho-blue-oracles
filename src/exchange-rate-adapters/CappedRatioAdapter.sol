// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.19;

import {ErrorsLib} from "./libraries/ErrorsLib.sol";

/// @title CappedRatioAdapter
/// @author Morpho Labs
/// @custom:contact security@morpho.org
/// @notice Abstract exchange rate price feed which caps the ratio to a max growth rate per year
abstract contract CappedRatioAdapter {
    /// @notice Ratio at the time of snapshot
    uint104 private _snapshotRatio;

    /// @notice Timestamp at the time of snapshot
    uint48 private _snapshotTimestamp;

    /// @notice Ratio growth per second
    uint104 private _maxRatioGrowthPerSecond;

    /// @notice Max yearly growth percent
    uint256 public immutable MAX_YEARLY_RATIO_GROWTH_PERCENT;

    /// @notice The minimum time which must pass before a new snapshot can be taken
    uint256 public immutable MINIMUM_SNAPSHOT_GAP;

    /// @notice Maximum percentage factor (100.00%)
    uint256 public constant PERCENTAGE_FACTOR = 1e4;

    /// @notice Number of seconds per year (365 days)
    uint256 public constant SECONDS_PER_YEAR = 365 days;

    /// @notice Minimal time while ratio should not overflow, in years
    uint256 public constant MINIMAL_RATIO_INCREASE_LIFETIME_YRS = 10;

    event SnapshotTaken(
      uint256 snapshotRatio,
      uint256 snapshotTimestamp,
      uint256 maxRatioGrowthPerSecond
    );

    constructor(uint256 maxYearlyRatioGrowthPct, uint256 minSnapshotGap) {
        MAX_YEARLY_RATIO_GROWTH_PERCENT = maxYearlyRatioGrowthPct;
        MINIMUM_SNAPSHOT_GAP = minSnapshotGap;
    }

    /// @notice Permisionless for anyone to take a new snapshot
    /// @dev The effect of calling this is to rebase the maxRatio() calculation from the ratio
    /// as of now. It will revert if the current ratio is greater than the existing maxRatio()
    /// Taking a new snapsho will effectively reduce the new `maxRatio()`, because the latest `getRatio()` 
    /// will realistically be less now vs if we were to applying the previous max annual growth rate 
    /// allowed on the old snapshot to now.
    function takeSnapshot() public {
        // A new snapshot can only be taken once every `MINIMUM_SNAPSHOT_GAP`
        require(block.timestamp > _snapshotTimestamp + MINIMUM_SNAPSHOT_GAP, ErrorsLib.SNAPSHOT_TOO_SOON);

        // Ensure the latest ratio is less than or equal to the previous max ratio.
        uint256 ratio = getRatio();
        uint256 maxRatio = getMaxRatio();
        require(ratio > 0 && (maxRatio == 0 || ratio <= maxRatio), ErrorsLib.INVALID_SNAPSHOT_RATIO);

        // The growth rate per second is rounded down, so effective growth rate
        // may be a little under the MAX_YEARLY_RATIO_GROWTH_PERCENT
        uint104 maxRatioGrowthPerSecond = uint104(
            (ratio * MAX_YEARLY_RATIO_GROWTH_PERCENT)
            / PERCENTAGE_FACTOR
            / SECONDS_PER_YEAR
        );

        // Ensure the ratio on the current growth speed can't overflow in 
        // less then MINIMAL_RATIO_INCREASE_LIFETIME_YRS years
        require(
            ratio + (maxRatioGrowthPerSecond * SECONDS_PER_YEAR * MINIMAL_RATIO_INCREASE_LIFETIME_YRS) < type(uint104).max,
            ErrorsLib.SNAPSHOT_MAY_OVERFLOW_SOON
        );
        
        emit SnapshotTaken(
            ratio,
            block.timestamp,
            maxRatioGrowthPerSecond
        );

        _snapshotRatio = uint104(ratio);
        _snapshotTimestamp = uint48(block.timestamp);
        _maxRatioGrowthPerSecond = maxRatioGrowthPerSecond;
    }

    /// @dev Returns zero for roundId, startedAt, updatedAt and answeredInRound.
    /// @dev Silently overflows if `amountForShare`'s return value is greater than `type(int256).max`.
    function getCappedRatio() public view returns (uint256) {
        uint256 currentRatio = getRatio();
        uint256 maxRatio = getMaxRatio();

        if (maxRatio < currentRatio) {
            currentRatio = maxRatio;
        }

        return currentRatio;
    }

    /// @notice Whether the price is currently capped to the `MAX_YEARLY_RATIO_GROWTH_PERCENT`
    function isCapped() public view returns (bool) {
        uint256 currentRatio = getRatio();
        uint256 maxRatio = getMaxRatio();
        return currentRatio > maxRatio;
    }
    
    /// @notice Returns the latest snapshot data
    function getSnapshot() external view returns (uint256, uint256, uint256, uint256) {
        return (
            _snapshotRatio, 
            _snapshotTimestamp, 
            _maxRatioGrowthPerSecond, 
            MAX_YEARLY_RATIO_GROWTH_PERCENT
        );
    }

    /// @notice Returns the current exchange ratio of the LST/LRT to the underlying asset
    function getRatio() public virtual view returns (uint256);

    /// @notice Returns the maximum possible ratio allowed given the latest snapshot and a
    /// max growth rate.
    function getMaxRatio() public view returns (uint256) {
        return uint256(_snapshotRatio) + _maxRatioGrowthPerSecond * (block.timestamp - _snapshotTimestamp);
    }
}
