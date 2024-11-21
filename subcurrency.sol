// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Coin {
    // State Variables
    address public minter;
    uint public totalSupply;
    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) public allowances;

    // Events
    event Sent(address indexed from, address indexed to, uint amount);
    event Mint(address indexed to, uint amount);
    event Burn(address indexed from, uint amount);
    event Approval(address indexed owner, address indexed spender, uint amount);
    event OwnershipTransferred(address indexed oldMinter, address indexed newMinter);

    // Modifiers
    modifier onlyMinter() {
        require(msg.sender == minter, "Only the minter can perform this action");
        _;
    }

    constructor() {
        minter = msg.sender;
    }

    // Mint new coins
    function mint(address receiver, uint amount) public onlyMinter {
        require(receiver != address(0), "Invalid address");
        balances[receiver] += amount;
        totalSupply += amount;
        emit Mint(receiver, amount);
    }

    // Burn tokens to reduce supply
    function burn(uint amount) public {
        require(balances[msg.sender] >= amount, "Insufficient balance to burn");
        balances[msg.sender] -= amount;
        totalSupply -= amount;
        emit Burn(msg.sender, amount);
    }

    // Transfer tokens to another address
    function transfer(address receiver, uint amount) public {
        require(receiver != address(0), "Invalid address");
        require(balances[msg.sender] >= amount, "Insufficient balance");
        balances[msg.sender] -= amount;
        balances[receiver] += amount;
        emit Sent(msg.sender, receiver, amount);
    }

    // Approve another account to spend on your behalf
    function approve(address spender, uint amount) public {
        require(spender != address(0), "Invalid address");
        allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
    }

    // Transfer from an approved account
    function transferFrom(address owner, address receiver, uint amount) public {
        require(receiver != address(0), "Invalid address");
        require(allowances[owner][msg.sender] >= amount, "Allowance exceeded");
        require(balances[owner] >= amount, "Insufficient balance");

        balances[owner] -= amount;
        allowances[owner][msg.sender] -= amount;
        balances[receiver] += amount;

        emit Sent(owner, receiver, amount);
    }

    // Transfer ownership of the minter role
    function transferOwnership(address newMinter) public onlyMinter {
        require(newMinter != address(0), "Invalid address");
        emit OwnershipTransferred(minter, newMinter);
        minter = newMinter;
    }
}
