// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @author @ownerlessinc | @alextnetto | @Blockful_io
 * @dev This contract will never truly exist in storage.
 * It will live and die solely for deleting Ethereum.
 *
 * !IMPORTANT: `selfdestruct` has been deprecated.
 * The underlying opcode will eventually undergo breaking
 * changes, and its use is not recommended.
 */
contract Blackhole {
    function suckMyEth() external payable {
        assembly {
            selfdestruct(address())
        }
    }
}
