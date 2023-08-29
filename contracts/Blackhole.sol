// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract Blackhole {
    function suckMyEther() external payable {
        selfdestruct(payable(address(this)));
    }
}
