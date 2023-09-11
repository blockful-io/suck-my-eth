// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC20} from "./IERC20.sol";
import {IERC20Errors} from "./IERC20Errors.sol";
import {IERC20Permit} from "./IERC20Permit.sol";
import {IERC20Supply} from "./IERC20Supply.sol";
import {Ownable} from "./Ownable.sol";

/**
 * @author @ownerlessinc | @Blockful_io
 * @dev Lightweight ERC20 with Permit and Ownable extensions.
 */
contract BlackholeToken is
    IERC20,
    IERC20Errors,
    IERC20Permit,
    IERC20Supply,
    Ownable
{
    /// @dev The bytes32 signature of the permit function and args name and type.
    bytes32 public constant PERMIT_TYPEHASH =
        keccak256(
            "Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"
        );

    /// @dev See {IERC20Permit-DOMAIN_SEPARATOR}.
    bytes32 public immutable DOMAIN_SEPARATOR;

    /// @dev The name of the Token.
    string public name;

    /// @dev The tick of the Token.
    string public symbol;

    /// @dev The total supply of the Token.
    uint256 public totalSupply;

    /// @dev Map accounts to spender to the allowed transfereable amount.
    mapping(address account => mapping(address spender => uint256))
        public allowance;

    /// @dev Map accounts to balance of Tokens.
    mapping(address account => uint256) public balanceOf;

    /// @dev Map accounts to its current nonce.
    mapping(address => uint256) public nonces;

    /**
     * @dev Sets the values for {name}, {symbol} and {owner}.
     *
     * https://eips.ethereum.org/EIPS/eip-712[EIP 712] is a standard for
     * hashing and signing of typed structured data.
     */
    constructor(
        string memory _name,
        string memory _symbol,
        address initialOwner
    ) Ownable(initialOwner) {
        name = _name;
        symbol = _symbol;

        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256(
                    "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
                ),
                keccak256(bytes(name)),
                keccak256(bytes("1")),
                block.chainid,
                address(this)
            )
        );
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the default value returned by this function, unless
     * it's overridden.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20Permit-permit}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {IERC20Permit-nonces}).
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

        // Overflow not possible: nonces will never reach max uint256.
        unchecked {
            address recoveredAddress = ecrecover(
                keccak256(
                    abi.encodePacked(
                        hex"19_01",
                        DOMAIN_SEPARATOR,
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
            if (recoveredAddress != owner) {
                revert ERC2612InvalidSigner(recoveredAddress, owner);
            }
        }

        allowance[owner][spender] = value;

        emit Approval(owner, spender, value);
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     */
    function approve(address spender, uint256 amount) public returns (bool) {
        allowance[msg.sender][spender] = amount;

        emit Approval(msg.sender, spender, amount);

        return true;
    }

    /**
     * @dev See {IERC20-increaseAllowance}.
     */
    function increaseAllowance(
        address spender,
        uint256 addedValue
    ) public returns (bool) {
        // Overflow check required: allowance should never overflow
        uint256 updatedAllowance = allowance[msg.sender][spender] + addedValue;

        allowance[msg.sender][spender] = updatedAllowance;

        emit Approval(msg.sender, spender, updatedAllowance);

        return true;
    }

    /**
     * @dev See {IERC20-decreaseAllowance}.
     *
     * Requirements:
     *
     * - `spender` must have allowance for the caller of at least
     * `requestedDecrease`.
     */
    function decreaseAllowance(
        address spender,
        uint256 requestedDecrease
    ) public returns (bool) {
        uint256 currentAllowance = allowance[msg.sender][spender];
        if (currentAllowance < requestedDecrease) {
            revert ERC20FailedDecreaseAllowance(
                spender,
                currentAllowance,
                requestedDecrease
            );
        }

        unchecked {
            // Underflow not possible: requestedDecrease <= currentAllowance.
            allowance[msg.sender][spender] =
                currentAllowance -
                requestedDecrease;

            emit Approval(
                msg.sender,
                spender,
                currentAllowance - requestedDecrease
            );
        }

        return true;
    }

    /**
     * @dev See {IERC20-mint}.
     *
     * Requirements:
     *
     * - the caller must be the contract `owner`.
     *
     * NOTE: The purpose of this function is solely to mint $BLACK by
     * deleting ETH from the total supply.
     */
    function mint(address to, uint256 amount) public onlyOwner {
        // Overflow check required: totalSupply should never overflow
        totalSupply += amount;

        unchecked {
            // Overflow not possible: amount <= totalSupply.
            balanceOf[to] += amount;
        }

        emit Transfer(address(0), to, amount);
    }

    /**
     * @dev See {IERC20-burn}.
     *
     * Requirements:
     *
     * - the caller must have a balance of at least `amount`.
     */
    function burn(uint256 amount) public {
        uint256 fromBalance = balanceOf[msg.sender];
        if (fromBalance < amount) {
            revert ERC20InsufficientBalance(msg.sender, fromBalance, amount);
        }

        unchecked {
            // Underflow not possible: amount <= totalSupply or amount <= fromBalance <= totalSupply.
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

        // Underflow and overflow not possible: amount <= totalSupply or amount <= fromBalance <= totalSupply.
        unchecked {
            balanceOf[msg.sender] = fromBalance - amount;
            balanceOf[to] += amount;
        }

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
            // Underflow not possible: amount <= currentAllowance
            unchecked {
                allowance[from][msg.sender] = currentAllowance - amount;
            }
        }

        uint256 fromBalance = balanceOf[from];
        if (fromBalance < amount) {
            revert ERC20InsufficientBalance(from, fromBalance, amount);
        }

        // Underflow and overflow not possible: amount <= fromBalance and amount <= totalSupply.
        unchecked {
            balanceOf[from] = fromBalance - amount;
            balanceOf[to] += amount;
        }

        emit Transfer(from, to, amount);

        return true;
    }

    /**
     * @dev See {IERC20Permit-permitTransfer}.
     *
     * Requirements:
     *
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use `owner`'s current nonce (see {IERC20Permit-nonces}).
     */
    function permitTransfer(
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

        // Overflow not possible: nonces will never reach max uint256.
        unchecked {
            bytes32 structHash = keccak256(
                abi.encode(
                    PERMIT_TYPEHASH,
                    owner,
                    spender,
                    value,
                    nonces[owner]++,
                    deadline
                )
            );
            address recoveredAddress = ecrecover(
                keccak256(
                    abi.encodePacked(hex"19_01", DOMAIN_SEPARATOR, structHash)
                ),
                v,
                r,
                s
            );
            if (recoveredAddress != owner) {
                revert ERC2612InvalidSigner(recoveredAddress, owner);
            }
        }

        uint256 fromBalance = balanceOf[owner];
        if (fromBalance < value) {
            revert ERC20InsufficientBalance(owner, fromBalance, value);
        }

        // Underflow and overflow not possible: value <= totalSupply or value <= fromBalance <= totalSupply.
        unchecked {
            balanceOf[owner] = fromBalance - value;
            balanceOf[spender] += value;
        }

        emit Transfer(owner, spender, value);
    }
}
