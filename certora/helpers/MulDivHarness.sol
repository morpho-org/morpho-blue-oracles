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
            (uint256 prod1, uint256 prod0) = _product(x, y);
            if (prod1 == 0) return prod0 / denominator;
            if (denominator <= prod1) {
                revert ArithmeticLib.MathOverflowedMulDiv();
            }
            uint256 remainder;
            assembly {
                remainder := mulmod(x, y, denominator)
            }
            (prod1, prod0) = _subtract(prod1, prod0, remainder);
            uint256 twos;
            uint256 flipped;
            (denominator, twos, flipped) = _twos(denominator);
            prod0 = _shift(prod1, prod0, twos, flipped);
            uint256 inverse = _inverse(denominator);
            return _final(prod0, inverse);
        }
    }

    function product(uint256 x, uint256 y) external pure returns (uint256, uint256) {
        return _product(x, y);
    }

    function subtract(uint256 hi, uint256 lo, uint256 remainder) external pure returns (uint256, uint256) {
        return _subtract(hi, lo, remainder);
    }

    function twos(uint256 denominator) external pure returns (uint256, uint256, uint256) {
        return _twos(denominator);
    }

    function shift(uint256 hi, uint256 lo, uint256 twos_, uint256 flipped) external pure returns (uint256) {
        return _shift(hi, lo, twos_, flipped);
    }

    function inverse(uint256 denominator) external pure returns (uint256) {
        return _inverse(denominator);
    }

    function finalProduct(uint256 prod0, uint256 inverse_) external pure returns (uint256) {
        return _final(prod0, inverse_);
    }

    function seed(uint256 denominator) external pure returns (uint256) {
        return _seed(denominator);
    }

    function seedProduct(uint256 denominator, uint256 inverse_) external pure returns (uint256) {
        return mulmod(denominator, inverse_, 16);
    }

    function newton(uint256 denominator, uint256 inverse_) external pure returns (uint256) {
        return _newton(denominator, inverse_);
    }

    function _product(uint256 x, uint256 y) internal pure returns (uint256 prod1, uint256 prod0) {
        unchecked {
            prod0 = x * y;
            assembly {
                let mm := mulmod(x, y, not(0))
                prod1 := sub(sub(mm, prod0), lt(mm, prod0))
            }
        }
    }

    function _subtract(uint256 prod1, uint256 prod0, uint256 remainder) internal pure returns (uint256, uint256) {
        assembly {
            prod1 := sub(prod1, gt(remainder, prod0))
            prod0 := sub(prod0, remainder)
        }
        return (prod1, prod0);
    }

    function _twos(uint256 denominator) internal pure returns (uint256, uint256 twos_, uint256 flipped) {
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

    function _shift(uint256 prod1, uint256 prod0, uint256 twos, uint256 flipped) internal pure returns (uint256) {
        unchecked {
            assembly {
                prod0 := div(prod0, twos)
            }
            prod0 |= prod1 * flipped;
            return prod0;
        }
    }

    function _inverse(uint256 denominator) internal pure returns (uint256 inverse_) {
        uint256 inverse = _seed(denominator);
        inverse = _newton(denominator, inverse);
        inverse = _newton(denominator, inverse);
        inverse = _newton(denominator, inverse);
        inverse = _newton(denominator, inverse);
        inverse = _newton(denominator, inverse);
        inverse = _newton(denominator, inverse);
        return inverse;
    }

    function _seed(uint256 denominator) internal pure returns (uint256) {
        unchecked {
            return (3 * denominator) ^ 2;
        }
    }

    function _newton(uint256 denominator, uint256 inverse_) internal pure returns (uint256) {
        unchecked {
            return inverse_ * (2 - denominator * inverse_);
        }
    }

    function _final(uint256 prod0, uint256 inverse_) internal pure returns (uint256) {
        unchecked {
            return prod0 * inverse_;
        }
    }
}
