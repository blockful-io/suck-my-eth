// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./Blackhole.sol";

contract BlackholeFactory {
    function suckTheEther() public payable {
        new Blackhole{value: msg.value, salt: 0x0}();
    }
}
