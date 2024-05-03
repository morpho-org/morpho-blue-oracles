// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.19;

import {Test} from "../../lib/forge-std/src/Test.sol";
import {IWeEth} from "../../src/interfaces/etherfi/IWeEth.sol";
import {CappedRatioAdapter} from "../../src/exchange-rate-adapters/CappedRatioAdapter.sol";

contract MockWeEth is IWeEth {
    function getRate() external pure returns (uint256) {
        return 1.037312039562434994e18;
    }
}

contract MockAdapter is CappedRatioAdapter {
    IWeEth public immutable WEETH;

    constructor(IWeEth _weeth) CappedRatioAdapter(
        875,   // maxYearlyRatioGrowthPct
        7 days // minSnapshotGap
    ) {
        WEETH = _weeth;
        takeSnapshot();
    }

    /// @inheritdoc CappedRatioAdapter
    function getRatio() public override view returns (uint256) {
        // It is assumed that `getRate()` returns a price with 18 decimals precision.
        return WEETH.getRate();
    }
}

contract CappedRatioAdapterTest is Test {
    MockAdapter internal adapter;

    IWeEth internal WEETH;

    event SnapshotTaken(
      uint256 snapshotRatio,
      uint256 snapshotTimestamp,
      uint256 maxRatioGrowthPerSecond
    );

    function setUp() public {
        vm.warp(1714000000);
        WEETH = new MockWeEth();
        adapter = new MockAdapter(WEETH);
    }

    function test_MAX_YEARLY_RATIO_GROWTH_PERCENT() public {
        assertEq(adapter.MAX_YEARLY_RATIO_GROWTH_PERCENT(), 875);
    }

    function test_MINIMUM_SNAPSHOT_GAP() public {
        assertEq(adapter.MINIMUM_SNAPSHOT_GAP(), 7 days);
    }

    function test_constants() public {
        assertEq(adapter.PERCENTAGE_FACTOR(), 1e4);
        assertEq(adapter.SECONDS_PER_YEAR(), 365 days);
        assertEq(adapter.MINIMAL_RATIO_INCREASE_LIFETIME_YRS(), 10);
    }

    function test_getRatio() public {
        assertEq(adapter.getRatio(), WEETH.getRate());
    }

    function test_getMaxRatio() public {
        // At construction, the max ratio equals the latest snapshot
        uint256 startRatio = adapter.getRatio();
        assertEq(adapter.getMaxRatio(), startRatio);

        skip(65 days);
        assertEq(adapter.getMaxRatio(), 1.053475634698226994e18);

        skip(300 days);
        uint256 endRatio = adapter.getMaxRatio();
        assertEq(endRatio, 1.128076843017266994e18);
        uint256 growthRate = 100_000 * (endRatio - startRatio) / startRatio;
        assertEq(growthRate, 8749);
    }

    function test_takeSnapshot_success_flatRatio() public {
        // At construction, the max ratio equals the latest snapshot
        (
            uint256 sRatio, 
            uint256 sTimestamp, 
            uint256 maxRatioGrowthPerSec, 
            uint256 maxRatioGrowthPerYr
        ) = adapter.getSnapshot();

        // At construction, the max ratio equals the latest snapshot
        uint256 startRatio = adapter.getRatio();
        assertEq(startRatio, 1.037312039562434994e18);
        assertEq(sRatio, adapter.getRatio());
        assertEq(sTimestamp, block.timestamp);
        assertEq(maxRatioGrowthPerSec, 2878133037);
        assertEq(maxRatioGrowthPerYr, 875);
        assertEq(adapter.getMaxRatio(), startRatio);
        
        // Remains the same as time moves forward if no new snapshot
        skip(365 days);
        (
            sRatio, 
            sTimestamp, 
            maxRatioGrowthPerSec, 
            maxRatioGrowthPerYr
        ) = adapter.getSnapshot();
        assertEq(sRatio, startRatio);
        assertEq(sTimestamp, block.timestamp - 365 days);
        assertEq(maxRatioGrowthPerSec, 2878133037);
        assertEq(maxRatioGrowthPerYr, 875);
        assertEq(adapter.getMaxRatio(), 1.128076843017266994e18);

        // Take a new snapshot. Since the assets & totalSupply in weETH is the same, the 
        // maxRatioGrowthPerSec is the same
        vm.expectEmit(address(adapter));
        emit SnapshotTaken(startRatio, block.timestamp, 2878133037);
        adapter.takeSnapshot();
        (
            sRatio, 
            sTimestamp, 
            maxRatioGrowthPerSec, 
            maxRatioGrowthPerYr
        ) = adapter.getSnapshot();
        assertEq(sRatio, startRatio);
        assertEq(sTimestamp, block.timestamp);
        assertEq(maxRatioGrowthPerSec, 2878133037);
        assertEq(maxRatioGrowthPerYr, 875);
        assertEq(adapter.getMaxRatio(), startRatio);
    }

    function test_takeSnapshot_success_increasingRatio() public {
        // At construction, the max ratio equals the latest snapshot
        (
            uint256 sRatio, 
            uint256 sTimestamp, 
            uint256 maxRatioGrowthPerSec, 
            uint256 maxRatioGrowthPerYr
        ) = adapter.getSnapshot();

        // At construction, the max ratio equals the latest snapshot
        uint256 startRatio = adapter.getRatio();
        assertEq(startRatio, 1.037312039562434994e18);
        assertEq(sRatio, adapter.getRatio());
        assertEq(sTimestamp, block.timestamp);
        assertEq(maxRatioGrowthPerSec, 2878133037);
        assertEq(maxRatioGrowthPerYr, 875);
        assertEq(adapter.getMaxRatio(), startRatio);

        // Set the rate higher but less than the max
        uint256 mockRate = 1.1e18;
        vm.mockCall(
            address(WEETH),
            abi.encodeWithSelector(IWeEth.getRate.selector),
            abi.encode(mockRate)
        );

        // Remains the same as time moves forward if no new snapshot
        skip(365 days);
        (
            sRatio, 
            sTimestamp, 
            maxRatioGrowthPerSec, 
            maxRatioGrowthPerYr
        ) = adapter.getSnapshot();
        assertEq(sRatio, startRatio);
        assertEq(sTimestamp, block.timestamp - 365 days);
        assertEq(maxRatioGrowthPerSec, 2878133037);
        assertEq(maxRatioGrowthPerYr, 875);
        assertEq(adapter.getRatio(), mockRate);
        assertEq(adapter.getMaxRatio(), 1.128076843017266994e18);

        // Take a new snapshot. Since the assets & totalSupply in weETH is the same, the 
        // maxRatioGrowthPerSec is the same
        adapter.takeSnapshot();
        (
            sRatio, 
            sTimestamp, 
            maxRatioGrowthPerSec, 
            maxRatioGrowthPerYr
        ) = adapter.getSnapshot();
        assertEq(sRatio, mockRate);
        assertEq(sTimestamp, block.timestamp);
        assertEq(maxRatioGrowthPerSec, 3052067478);
        assertEq(maxRatioGrowthPerYr, 875);
        assertEq(adapter.getRatio(), mockRate);
        assertEq(adapter.getMaxRatio(), mockRate);

        skip(365 days);
        assertEq(adapter.getMaxRatio(), 1.196249999986208000e18);
    }

    function test_takeSnapshot_success_decreasingRatio() public {
        // At construction, the max ratio equals the latest snapshot
        (
            uint256 sRatio, 
            uint256 sTimestamp, 
            uint256 maxRatioGrowthPerSec, 
            uint256 maxRatioGrowthPerYr
        ) = adapter.getSnapshot();

        // At construction, the max ratio equals the latest snapshot
        uint256 startRatio = adapter.getRatio();
        assertEq(startRatio, 1.037312039562434994e18);
        assertEq(sRatio, adapter.getRatio());
        assertEq(sTimestamp, block.timestamp);
        assertEq(maxRatioGrowthPerSec, 2878133037);
        assertEq(maxRatioGrowthPerYr, 875);
        assertEq(adapter.getMaxRatio(), startRatio);

        // Set the rate higher but less than the max
        uint256 mockRate = 1.01e18;
        vm.mockCall(
            address(WEETH),
            abi.encodeWithSelector(IWeEth.getRate.selector),
            abi.encode(mockRate)
        );

        // Remains the same as time moves forward if no new snapshot
        skip(365 days);
        (
            sRatio, 
            sTimestamp, 
            maxRatioGrowthPerSec, 
            maxRatioGrowthPerYr
        ) = adapter.getSnapshot();
        assertEq(sRatio, startRatio);
        assertEq(sTimestamp, block.timestamp - 365 days);
        assertEq(maxRatioGrowthPerSec, 2878133037);
        assertEq(maxRatioGrowthPerYr, 875);
        assertEq(adapter.getRatio(), mockRate);
        assertEq(adapter.getMaxRatio(), 1.128076843017266994e18);

        // Take a new snapshot. Since the assets & totalSupply in weETH is the same, the 
        // maxRatioGrowthPerSec is the same
        adapter.takeSnapshot();
        (
            sRatio, 
            sTimestamp, 
            maxRatioGrowthPerSec, 
            maxRatioGrowthPerYr
        ) = adapter.getSnapshot();
        assertEq(sRatio, mockRate);
        assertEq(sTimestamp, block.timestamp);
        assertEq(maxRatioGrowthPerSec, 2802352866);
        assertEq(maxRatioGrowthPerYr, 875);
        assertEq(adapter.getRatio(), mockRate);
        assertEq(adapter.getMaxRatio(), mockRate);

        skip(365 days);
        assertEq(adapter.getMaxRatio(), 1.098374999982176000e18);
    }

    function test_takeSnapshot_fail_tooSoon() public {
        vm.expectRevert("snapshot too soon");
        adapter.takeSnapshot();

        skip(adapter.MINIMUM_SNAPSHOT_GAP()+1);
        adapter.takeSnapshot();
    }

    function test_takeSnapshot_fail_zeroRatio() public {
        skip(10 days);
        vm.mockCall(
            address(WEETH),
            abi.encodeWithSelector(IWeEth.getRate.selector),
            abi.encode(0)
        );

        vm.expectRevert("invalid snapshot ratio");
        adapter.takeSnapshot();
    }

    function test_takeSnapshot_fail_ratioTooHigh() public {
        skip(10 days);
        vm.mockCall(
            address(WEETH),
            abi.encodeWithSelector(IWeEth.getRate.selector),
            abi.encode(1.3e18)
        );

        vm.expectRevert("invalid snapshot ratio");
        adapter.takeSnapshot();
    }

    function test_takeSnapshot_fail_growthRate() public {
        uint256 mockRate = type(uint104).max - 100e18;
        vm.mockCall(
            address(WEETH),
            abi.encodeWithSelector(IWeEth.getRate.selector),
            abi.encode(mockRate)
        );
        vm.expectRevert("snapshot ratio may overflow soon");
        adapter = new MockAdapter(WEETH);
    }

    function test_getCappedRatio_under() public {
        skip(365 days);
        uint256 mockRate = 1.05e18;
        vm.mockCall(
            address(WEETH),
            abi.encodeWithSelector(IWeEth.getRate.selector),
            abi.encode(mockRate)
        );
        assertEq(adapter.getMaxRatio(), 1.128076843017266994e18);
        assertEq(adapter.isCapped(), false);
        assertEq(adapter.getCappedRatio(), mockRate);
    }

    function test_getCappedRatio_over() public {
        skip(365 days);
        uint256 mockRate = 1.3e18;
        vm.mockCall(
            address(WEETH),
            abi.encodeWithSelector(IWeEth.getRate.selector),
            abi.encode(mockRate)
        );
        assertEq(adapter.getMaxRatio(), 1.128076843017266994e18);
        assertEq(adapter.isCapped(), true);
        assertEq(adapter.getCappedRatio(), 1.128076843017266994e18);
    }
}
