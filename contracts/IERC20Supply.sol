// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

interface IERC20Supply {
    /**
     * @dev Creates an `amount` of tokens and assigns them to `to` by creating supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     */
    function mint(address to, uint256 amount) external;

    /**
     * @dev Destroys an `amount` of tokens from `from` by lowering the total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     */
    function burn(uint256 amount) external;
}
