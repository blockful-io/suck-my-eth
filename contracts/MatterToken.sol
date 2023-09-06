// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC20} from "./IERC20.sol";
import {IERC20Permit} from "./IERC20Permit.sol";
import {Ownable} from "./Ownable.sol";
import {IERC20Errors} from "./IERC20Errors.sol";

/**
 * @title ERC20
 * @author @ownerlessinc | @Blockful_io
 * @dev Implementation without the rubish checks of OpenZeppelin.
 */
contract MatterToken is IERC20, IERC20Permit, IERC20Errors, Ownable {
    bytes32 private constant PERMIT_TYPEHASH =
        keccak256(
            "Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"
        );

    bytes32 private immutable DOMAIN_TYPEHASH = DOMAIN_SEPARATOR();

    string public name;
    string public symbol;
    uint8 public constant decimals = 18;

    uint256 public totalSupply;

    mapping(address account => mapping(address spender => uint256))
        public allowance;

    mapping(address account => uint256) public balanceOf;

    mapping(address => uint256) public nonces;

    /**
     * @dev Sets the values for {name}, {symbol} and {decimals}.
     *
     * All three of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(
        string memory _name,
        string memory _symbol,
        address _initialOwner
    ) Ownable(_initialOwner) {
        name = _name;
        symbol = _symbol;
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     */
    function approve(address spender, uint256 amount) public returns (bool) {
        allowance[msg.sender][spender] = amount;

        emit Approval(msg.sender, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20Permit-permit}.
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public {
        if (block.timestamp > deadline) {
            revert ERC2612ExpiredSignature(deadline);
        }

        unchecked {
            address signer = ecrecover(
                keccak256(
                    abi.encodePacked(
                        hex"1901",
                        DOMAIN_TYPEHASH,
                        keccak256(
                            abi.encode(
                                PERMIT_TYPEHASH,
                                owner,
                                spender,
                                value,
                                nonces[owner]++,
                                deadline
                            )
                        )
                    )
                ),
                v,
                r,
                s
            );

            if (signer != owner) {
                revert ERC2612InvalidSigner(signer, owner);
            }

            allowance[owner][spender] = value;
        }

        emit Approval(owner, spender, value);
    }

    /**
     * @dev See {IERC20Permit-DOMAIN_SEPARATOR}.
     */
    function DOMAIN_SEPARATOR() public view returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    keccak256(
                        "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
                    ),
                    keccak256(bytes(name)),
                    keccak256("1"),
                    block.chainid,
                    address(this)
                )
            );
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     */
    function increaseAllowance(
        address spender,
        uint256 addedValue
    ) public returns (bool) {
        // Should this overflow because of safemath?
        uint256 updatedAllowance = allowance[msg.sender][spender] + addedValue;

        unchecked {
            allowance[msg.sender][spender] = updatedAllowance;
        }

        emit Approval(msg.sender, spender, updatedAllowance);

        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` must have allowance for the caller of at least
     * `requestedDecrease`.
     *
     * NOTE: Although this function is designed to avoid double spending with {approval},
     * it can still be frontrunned, preventing any attempt of allowance reduction.
     */
    function decreaseAllowance(
        address spender,
        uint256 requestedDecrease
    ) public returns (bool) {
        // Will revert in case of overflow because of automatic safeMath
        uint256 updatedAllowance = allowance[msg.sender][spender] -
            requestedDecrease;
        // if (currentAllowance < requestedDecrease) {
        //     revert ERC20FailedDecreaseAllowance(
        //         spender,
        //         currentAllowance,
        //         requestedDecrease
        //     );
        // }
        unchecked {
            allowance[msg.sender][spender] = updatedAllowance;
        }

        emit Approval(msg.sender, spender, updatedAllowance);

        return true;
    }

    /**
     * @dev Creates an `amount` of tokens and assigns them to `to` by creating supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     */
    function mint(address to, uint256 amount) public onlyOwner {
        // Overflow check required: totalSupply should never overflows
        totalSupply += amount;
        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(address(0), to, amount);
    }

    /**
     * @dev Destroys an `amount` of tokens from `from` by lowering the total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     */
    function burn(uint256 amount) public {
        uint256 fromBalance = balanceOf[msg.sender];
        if (fromBalance < amount) {
            revert ERC20InsufficientBalance(msg.sender, fromBalance, amount);
        }

        unchecked {
            // Overflow not possible: value <= totalSupply or value <= fromBalance <= totalSupply.
            totalSupply -= amount;
            balanceOf[msg.sender] -= amount;
        }

        emit Transfer(msg.sender, address(0), amount);
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public returns (bool) {
        uint256 fromBalance = balanceOf[msg.sender];
        if (fromBalance < amount) {
            revert ERC20InsufficientBalance(msg.sender, fromBalance, amount);
        }

        unchecked {
            balanceOf[msg.sender] = fromBalance - amount;
            balanceOf[to] += amount;
        }

        // gas? var or msg.sender
        emit Transfer(msg.sender, to, amount);

        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for `from`'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public returns (bool) {
        uint256 currentAllowance = allowance[from][msg.sender];
        if (currentAllowance != type(uint256).max) {
            if (currentAllowance < amount) {
                revert ERC20InsufficientAllowance(
                    msg.sender,
                    currentAllowance,
                    amount
                );
            }
            unchecked {
                allowance[from][msg.sender] = currentAllowance - amount;
            }
        }

        uint256 fromBalance = balanceOf[from];
        if (fromBalance < amount) {
            revert ERC20InsufficientBalance(from, fromBalance, amount);
        }

        unchecked {
            balanceOf[from] = fromBalance - amount;
            balanceOf[to] += amount;
        }

        // gas? var or msg.sender
        emit Transfer(from, to, amount);

        return true;
    }
}
