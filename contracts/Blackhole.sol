// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract Blackhole {
    function suckMyEth() external payable {
        selfdestruct(payable(address(this)));
    }
}
