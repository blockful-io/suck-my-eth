// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract Blackhole {
    function suckMyEth() external payable {
        assembly {
            selfdestruct(address())
        }
    }
}
