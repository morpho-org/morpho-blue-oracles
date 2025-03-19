pragma solidity ^0.8.0;
import "../lib/forge-std/src/Test.sol";
import "@pythnetwork/pyth-sdk-solidity/MockPyth.sol";
import "../src/morpho-pyth/MorphoPythOracle.sol";
import "./helpers/Constants.sol";
import {console} from "forge-std/console.sol";

contract MorphoPythOracleTest is Test {
    MockPyth public mockPyth;
    MorphoPythOracle public oracle;

    function setUp() public {
        mockPyth = new MockPyth(60, 1);

        // Create price feed update data for WBTC/USD
        bytes[] memory updateData = new bytes[](2);
        updateData[0] = mockPyth.createPriceFeedUpdateData(
            pythWbtcUsdFeed,
            30000 * 1e8, // Price of 30,000 USD
            0, // Confidence interval
            -8, // Expo (-8 means price is multiplied by 10^8)
            30000 * 1e8, // EMA price
            0, // EMA Confidence interval
            uint64(block.timestamp),
            uint64(block.timestamp)
        );

        updateData[1] = mockPyth.createPriceFeedUpdateData(
            pythUsdtUsdFeed,
            1 * 1e8, // Price of 1 USD
            0, // Confidence interval
            -6, // Expo (-6 means price is multiplied by 10^6)
            1 * 1e8, // EMA price
            0, // EMA Confidence interval
            uint64(block.timestamp),
            uint64(block.timestamp)
        );
        // Update the price feed
        mockPyth.updatePriceFeeds{value: 2}(updateData);
        assertEq(mockPyth.getPriceUnsafe(pythWbtcUsdFeed).price, 30000 * 1e8);
        assertEq(mockPyth.getPriceUnsafe(pythUsdtUsdFeed).price, 1 * 1e8);

        oracle = new MorphoPythOracle(
            address(mockPyth),
            vaultZero,
            1,
            pythWbtcUsdFeed,
            pythFeedZero,
            pythWbtcUsdTokenDecimals,
            vaultZero,
            1,
            pythUsdtUsdFeed,
            pythFeedZero,
            pythUsdtUsdTokenDecimals,
            oneHour
        );
    }

    function testInitialSetup() public {
        assertTrue(address(oracle) != address(0), "Oracle not deployed");
    }

    function testPythOracleWbtcUsdt() public {
        assertEq(
            oracle.price(),
            ((uint256(int256(mockPyth.getPriceUnsafe(pythWbtcUsdFeed).price))) *
                10 **
                    (36 +
                        pythUsdtUsdTokenDecimals +
                        uint256(-1 * int256(-6)) -
                        pythWbtcUsdTokenDecimals -
                        uint256(-1 * int256(-8)))) /
                uint256(int256(mockPyth.getPriceUnsafe(pythUsdtUsdFeed).price))
        );
    }
}
