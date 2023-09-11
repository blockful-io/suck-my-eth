# BLACKHOLE TOKEN

Welcome to the end of the Universe. Here you can convert your remaining ETH into BLACK.

Solidity has an opcode called `selfdestruct`, which will send all remaining ETH to the parameter passed into the selfdestruct function. When you pass the address of the contract about to be destructed as address(this) or in assembly address(), the remaining ETH will be permanently destroyed.

This method permanently reduces the Ethereum total supply. Different than sending Eth to the Zero address, which won't actually delete the ETH.

## Game

For every Ethereum sucked into the Blackhole a BLACK Token will be minted to the `msg.sender`.

## Features

- Permit: Allows to operate allowances by matching the `signer`.
- Approve: Allows a `spender` to move the tokens of `caller`.
- Increase Allowance: Increases the amount of tokens `spender` can move.
- Decrease Allowance: Decreases the amount of tokens `spender` can move.
- Mint: Send ETH to be deleted and receive BLACK.
- Burn: Burn BLACK Tokens and lower the total supply.
- Transfer: Send Tokens from the `caller` into the `target`s balance.
- Transfer From: Send Tokens from an authorized `owner` into the `target`'s balance as the `spender`.
- Permit Transfer: Send Tokens from an authorized `owner` matching the permit `signer` into the `target`'s balance as the `spender`.

## Test

Run the following commands to experiment

```shell
yarn
yarn compile
yarn test
```
