// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Blackhole} from "./Blackhole.sol";
import {IERC20Mint} from "./interfaces/IERC20Mint.sol";

/**
 * @author @ownerlessinc | @alextnetto | @Blockful_io
 * @dev This contract is the main factory contract to create Blackhole contracts.
 *
 * All Ethereum sent to this contract will be sucked into the Blackhole and
 * disappear forever from the total supply of Eth. This happens because the
 * selfdestruct function which lies inside the Blackhole contract can send
 * ether to itself prior to set the address balance to 0.
 *
 * To allow for a gamefication of this feature, the contract will be minting
 * $BLACK tokens 1:1 for each deleted ETH
 *
 * !IMPORTANT: This permanently reduces the Ethereum total supply.
 */
contract UniverseFactory {
    /**
     * @dev The official $BLACK Token address.
     */
    address public immutable BlackholeToken;

    /**
     * @dev Sets the address for {BlackholeToken}.
     */
    constructor(address blackholeToken) {
        BlackholeToken = blackholeToken;
    }

    /**
     * @dev Creates a new Blackhole contract and redirects the ETH
     * sent to this function to the new contract to be destroyed.
     *
     * The amount of ETH sent is also minted as BLACK tokens for the sender.
     *
     * IMPORTANT: Any ethereum dust in the factory will be destroyed as well,
     * but it won't reward with $BLACK tokens.
     *
     * NOTE: The contract will be destroyed in the same transaction.
     */
    receive() external payable {
        Blackhole please = new Blackhole();
        please.suckMyEth{value: address(this).balance}();
        IERC20Mint(BlackholeToken).mint(msg.sender, msg.value);
    }
}
