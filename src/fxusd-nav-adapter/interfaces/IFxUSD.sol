// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.5.0;

interface IFxUSD {
    /// @notice Return the nav of fxUSD.
    function nav() external view returns (uint256);
}
