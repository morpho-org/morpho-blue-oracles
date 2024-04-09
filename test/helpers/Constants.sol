// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import {IERC4626} from "../../src/morpho-chainlink/interfaces/IERC4626.sol";
import {MinimalAggregatorV3Interface} from "../../src/interfaces/MinimalAggregatorV3Interface.sol";

MinimalAggregatorV3Interface constant feedZero = MinimalAggregatorV3Interface(address(0));
// 8 decimals of precision
MinimalAggregatorV3Interface constant btcUsdFeed = MinimalAggregatorV3Interface(0xF4030086522a5bEEa4988F8cA5B36dbC97BeE88c);
// 8 decimals of precision
MinimalAggregatorV3Interface constant usdcUsdFeed = MinimalAggregatorV3Interface(0x8fFfFfd4AfB6115b954Bd326cbe7B4BA576818f6);
// 18 decimals of precision
MinimalAggregatorV3Interface constant btcEthFeed = MinimalAggregatorV3Interface(0xdeb288F737066589598e9214E782fa5A8eD689e8);
// 8 decimals of precision
MinimalAggregatorV3Interface constant wBtcBtcFeed = MinimalAggregatorV3Interface(0xfdFD9C85aD200c506Cf9e21F1FD8dd01932FBB23);
// 18 decimals of precision
MinimalAggregatorV3Interface constant stEthEthFeed = MinimalAggregatorV3Interface(0x86392dC19c0b719886221c78AB11eb8Cf5c52812);
// 18 decimals of precision
MinimalAggregatorV3Interface constant usdcEthFeed = MinimalAggregatorV3Interface(0x986b5E1e1755e3C2440e960477f25201B0a8bbD4);
// 8 decimals of precision
MinimalAggregatorV3Interface constant ethUsdFeed = MinimalAggregatorV3Interface(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419);
// 18 decimals of precision
MinimalAggregatorV3Interface constant daiEthFeed = MinimalAggregatorV3Interface(0x773616E4d11A78F511299002da57A0a94577F1f4);

IERC4626 constant vaultZero = IERC4626(address(0));
IERC4626 constant sDaiVault = IERC4626(0x83F20F44975D03b1b09e64809B757c47f942BEeA);
IERC4626 constant sfrxEthVault = IERC4626(0xac3E018457B222d93114458476f3E3416Abbe38F);
