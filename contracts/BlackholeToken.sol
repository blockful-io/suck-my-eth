// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC20} from "./ERC20.sol";
import {Ownable} from "./Ownable.sol";

/**
 * @author @ownerlessinc | @Blockful_io
 * @dev Implementation of the Blackhole Token with  Blockful's ERC20.
 */
contract BlackholeToken is ERC20, Ownable {
    /**
     * @dev Sets the {name}, {symbol}, {owner} of the contract.
     */
    constructor(
        string memory name,
        string memory symbol,
        address owner
    ) ERC20(name, symbol) Ownable(owner) {}

    /**
     * @dev Mint an `amount` of tokens to the `to`.
     *
     * Requirements:
     *
     * - caller must be `owner`
     */
    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }
}
