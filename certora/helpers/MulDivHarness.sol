// SPDX-License-Identifier: MIT
// Copyright (c) 2025 Morpho Association
pragma solidity 0.8.28;

import {ArithmeticLib} from "../../src/morpho-chainlink/libraries/ArithmeticLib.sol";

contract MulDivHarness {
    function mulDiv(uint256 x, uint256 y, uint256 denominator) external pure returns (uint256) {
        return ArithmeticLib.mulDiv(x, y, denominator);
    }

    function mulDivSteps(uint256 x, uint256 y, uint256 denominator) external pure returns (uint256) {
        unchecked {
            (uint256 prod1, uint256 prod0) = product(x, y);
            if (prod1 == 0) return prod0 / denominator;
            if (denominator <= prod1) {
                revert ArithmeticLib.MathOverflowedMulDiv();
            }
            uint256 remainder;
            assembly {
                remainder := mulmod(x, y, denominator)
            }
            (prod1, prod0) = subtract(prod1, prod0, remainder);
            uint256 twosFactor;
            uint256 flipped;
            (denominator, twosFactor, flipped) = twos(denominator);
            prod0 = shift(prod1, prod0, twosFactor, flipped);
            uint256 inv = inverse(denominator);
            return finalProduct(prod0, inv);
        }
    }

    function product(uint256 x, uint256 y) public pure returns (uint256 prod1, uint256 prod0) {
        unchecked {
            prod0 = x * y;
            assembly {
                let mm := mulmod(x, y, not(0))
                prod1 := sub(sub(mm, prod0), lt(mm, prod0))
            }
        }
    }

    function subtract(uint256 prod1, uint256 prod0, uint256 remainder) public pure returns (uint256, uint256) {
        assembly {
            prod1 := sub(prod1, gt(remainder, prod0))
            prod0 := sub(prod0, remainder)
        }
        return (prod1, prod0);
    }

    function twos(uint256 denominator) public pure returns (uint256, uint256 twos_, uint256 flipped) {
        unchecked {
            uint256 twos = denominator & (0 - denominator);
            twos_ = twos;
            assembly {
                denominator := div(denominator, twos)
                twos := add(div(sub(0, twos), twos), 1)
            }
            return (denominator, twos_, twos);
        }
    }

    function shift(uint256 prod1, uint256 prod0, uint256 twos, uint256 flipped) public pure returns (uint256) {
        unchecked {
            assembly {
                prod0 := div(prod0, twos)
            }
            prod0 |= prod1 * flipped;
            return prod0;
        }
    }

    function inverse(uint256 denominator) public pure returns (uint256 inverse_) {
        uint256 inverse = seed(denominator);
        inverse = newton(denominator, inverse, 2 ** 4);
        inverse = newton(denominator, inverse, 2 ** 8);
        inverse = newton(denominator, inverse, 2 ** 16);
        inverse = newton(denominator, inverse, 2 ** 32);
        inverse = newton(denominator, inverse, 2 ** 64);
        inverse = newton(denominator, inverse, 2 ** 128);
        return inverse;
    }

    function seed(uint256 denominator) public pure returns (uint256) {
        unchecked {
            return (3 * denominator) ^ 2;
        }
    }

    // The last uint256 argument is a ghost variable.
    function newton(uint256 denominator, uint256 inverse_, uint256) public pure returns (uint256) {
        unchecked {
            return inverse_ * (2 - denominator * inverse_);
        }
    }

    function finalProduct(uint256 prod0, uint256 inverse_) public pure returns (uint256) {
        unchecked {
            return prod0 * inverse_;
        }
    }
}
