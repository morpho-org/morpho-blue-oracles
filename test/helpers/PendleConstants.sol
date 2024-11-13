// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.21;

import {IPTOracle} from "../../src/pendle-pt-oracle-adapter/interfaces/IPTOracle.sol";

IPTOracle constant PT_ORACLE = IPTOracle(
    0x9a9Fa8338dd5E5B2188006f1Cd2Ef26d921650C2
);

address constant LBTC_MAR2025 = 0x70B70Ac0445C3eF04E314DFdA6caafd825428221;
address constant SUSDE_MAR2025 = 0xcDd26Eb5EB2Ce0f203a84553853667aE69Ca29Ce;
address constant PUFETH_DEC2024 = 0x676106576004EF54B4bD39Ce8d2B34069F86eb8f;
address constant STETH_DEC2027 = 0x34280882267ffa6383B363E278B027Be083bBe3b;
