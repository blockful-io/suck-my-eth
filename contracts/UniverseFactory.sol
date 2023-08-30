// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

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
 * @dev Factory contract to create Blackhole contracts which sucks all
 * the ETH sent to it by selfdestructing. This is a demonstration of
 * how to permanently delete Eth. This happens because the selfdestruct
 * can send ether to itself prior to set the address balance to 0.
 *
 * !IMPORTANT: This is permanently reduce ETH total supply.
 */
contract UniverseFactory {
    event BlackholeCreated(address indexed addr, uint256 ethAmount);

    /**
     * @dev Creates a new Blackhole contract and redirects the ETH
     * sent to this function to the new contract.
     * The contract will be destroyed in the same transaction.
     */
    function createBlackhole() external payable {
        Blackhole please = new Blackhole();
        please.suckMyEth{value: msg.value}();
    }
}
