// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Blackhole} from "./Blackhole.sol";

/**
 *   ______  __      ______  ______  __  __  ______ __  __  __
 *  /\  == \/\ \    /\  __ \/\  ___\/\ \/ / /\  ___/\ \/\ \/\ \
 *  \ \  __<\ \ \___\ \ \/\ \ \ \___\ \  _"-\ \  __\ \ \_\ \ \ \____
 *   \ \_____\ \_____\ \_____\ \_____\ \_\ \_\ \_\  \ \_____\ \_____\
 *    \/_____/\/_____/\/_____/\/_____/\/_/\/_/\/_/   \/_____/\/_____/
 *
 * @title UniverseFactory
 * @author @ownerlessinc | @alextnetto | @Blockful_io
 * @dev Factory contract to create Blackhole contracts which sucks
 * all the ETH sent to it by selfdestructing.This happens because the
 * selfdestruct can send ether to itself prior to set the address balance to 0.
 *
 * !IMPORTANT: This permanently reduces the Ethereum total supply.
 */
contract UniverseFactory {
    /**
     * @dev Creates a new Blackhole contract and redirects the ETH
     * sent to this function to the new contract.
     * The contract will be destroyed in the same transaction.
     */
    receive() external payable {
        Blackhole please = new Blackhole();
        please.suckMyEth{value: msg.value}();
    }
}
