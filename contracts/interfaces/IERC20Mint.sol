// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @dev Carries the mint function for hardcoded access from the {UniverseFactory}.
 */
interface IERC20Mint {
    function mint(address to, uint256 amount) external;
}
