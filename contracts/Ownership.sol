// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

error OwnableUnauthorizedAccount(address account);

abstract contract Ownership {
    address public owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    modifier onlyOwner() virtual {
        if (owner != msg.sender) {
            revert OwnableUnauthorizedAccount(msg.sender);
        }

        _;
    }

    constructor() {
        owner = msg.sender;

        emit OwnershipTransferred(address(0), msg.sender);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        owner = newOwner;

        emit OwnershipTransferred(msg.sender, newOwner);
    }
}
