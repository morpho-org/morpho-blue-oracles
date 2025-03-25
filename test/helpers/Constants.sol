// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import {IERC4626} from "../../src/interfaces/IERC4626.sol";
import {AggregatorV3Interface} from "../../src/morpho-chainlink/interfaces/AggregatorV3Interface.sol";

AggregatorV3Interface constant feedZero = AggregatorV3Interface(address(0));
// 8 decimals of precision
AggregatorV3Interface constant btcUsdFeed = AggregatorV3Interface(0xF4030086522a5bEEa4988F8cA5B36dbC97BeE88c);
// 8 decimals of precision
AggregatorV3Interface constant usdcUsdFeed = AggregatorV3Interface(0x8fFfFfd4AfB6115b954Bd326cbe7B4BA576818f6);
// 18 decimals of precision
AggregatorV3Interface constant btcEthFeed = AggregatorV3Interface(0xdeb288F737066589598e9214E782fa5A8eD689e8);
// 8 decimals of precision
AggregatorV3Interface constant wBtcBtcFeed = AggregatorV3Interface(0xfdFD9C85aD200c506Cf9e21F1FD8dd01932FBB23);
// 18 decimals of precision
AggregatorV3Interface constant stEthEthFeed = AggregatorV3Interface(0x86392dC19c0b719886221c78AB11eb8Cf5c52812);
// 18 decimals of precision
AggregatorV3Interface constant usdcEthFeed = AggregatorV3Interface(0x986b5E1e1755e3C2440e960477f25201B0a8bbD4);
// 8 decimals of precision
AggregatorV3Interface constant ethUsdFeed = AggregatorV3Interface(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419);
// 18 decimals of precision
AggregatorV3Interface constant daiEthFeed = AggregatorV3Interface(0x773616E4d11A78F511299002da57A0a94577F1f4);

IERC4626 constant vaultZero = IERC4626(address(0));
IERC4626 constant sDaiVault = IERC4626(0x83F20F44975D03b1b09e64809B757c47f942BEeA);
IERC4626 constant sfrxEthVault = IERC4626(0xac3E018457B222d93114458476f3E3416Abbe38F);

// Pyth contract addresses
address constant pythBaseContractAddress = 0x8250f4aF4B972684F7b336503E2D6dFeDeB1487a;
address constant pythEthereumContractAddress = 0x4305FB66699C3B2702D4d05CF36551390A4c69C6;

// Pyth Price Feed IDs
bytes32 constant pythFeedZero = 0x0000000000000000000000000000000000000000000000000000000000000000;
bytes32 constant pythWbtcUsdFeed = 0xc9d8b075a5c69303365ae23633d4e085199bf5c520a3b90fed1322a0342ffc33;
uint256 constant pythWbtcUsdTokenDecimals = 8;
bytes32 constant pythEthUsdFeed = 0xff61491a931112ddf1bd8147cd1b641375f79f5825126d665480874634fd0ace;
bytes32 constant pythUsdtUsdFeed = 0x2b89b9dc8fdf9f34709a5b106b472f0f39bb6ca9ce04b0fd7f2e971688e2e53b;
uint256 constant pythUsdtUsdTokenDecimals = 6;
bytes32 constant pythCbethUsdFeed = 0x15ecddd26d49e1a8f1de9376ebebc03916ede873447c1255d2d5891b92ce5717;
// Time constants
uint256 constant oneHour = 3600;
uint256 constant oneMinute = 60;