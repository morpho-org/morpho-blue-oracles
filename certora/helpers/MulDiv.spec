// SPDX-License-Identifier: MIT
// Copyright (c) 2025 Morpho Association

methods {
    function mulDiv(uint256, uint256, uint256) external returns (uint256) envfree;
    function mulDivSteps(uint256, uint256, uint256) external returns (uint256) envfree;
    function product(uint256, uint256) external returns (uint256, uint256) envfree;
    function subtract(uint256, uint256, uint256) external returns (uint256, uint256) envfree;
    function twos(uint256) external returns (uint256, uint256, uint256) envfree;
    function shift(uint256, uint256, uint256, uint256) external returns (uint256) envfree;
    function inverse(uint256) external returns (uint256) envfree;
    function finalProduct(uint256, uint256) external returns (uint256) envfree;
    function seed(uint256) external returns (uint256) envfree;
    function newton(uint256, uint256) external returns (uint256) envfree;
}

definition B() returns mathint = 2 ^ 256;

definition mulmod(uint256 x, uint256 y, uint256 m) returns mathint = m == 0 ? 0 : (x * y) % m;

definition wordShiftPre(uint256 t, uint256 flipped) returns bool = t > 0 && max_uint256 % t == t - 1 && flipped == (t == 1 ? 0 : max_uint256 / t + 1);

definition wordTwosPost(uint256 d, uint256 odd, uint256 t, uint256 flipped) returns bool = wordShiftPre(t, flipped) && t <= d && d % t == 0 && odd == d / t && odd % 2 == 1;
