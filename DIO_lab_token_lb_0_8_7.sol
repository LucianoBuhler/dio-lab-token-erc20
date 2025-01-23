// SPDX-License-Identifier: GPL-3.0
// Specifies the license under which the software is distributed
pragma solidity ^0.8.7;

// ERC Token Standard #20 Interface
// Provides the required interface for any ERC20 token compliance
interface ERC20Interface {
    // Returns the total token supply
    function totalSupply() external view returns (uint);

    // Returns the account balance of another account with address `tokenOwner`
    function balanceOf(address tokenOwner) external view returns (uint balance);

    // Returns the amount which `spender` is still allowed to withdraw from `tokenOwner`
    function allowance(address tokenOwner, address spender) external view returns (uint remaining);

    // Transfers `tokens` from the caller's account to another account with address `to`
    function transfer(address to, uint tokens) external returns (bool success);

    // Allows `spender` to withdraw from caller's account multiple times, up to the `tokens` amount
    function approve(address spender, uint tokens) external returns (bool success);

    // Transfers `tokens` from `from` address to `to` address, given caller has enough allowance
    function transferFrom(address from, address to, uint tokens) external returns (bool success);

    // Triggered when tokens are transferred, including zero value transfers
    event Transfer(address indexed from, address indexed to, uint tokens);

    // Triggered whenever approve(address spender, uint tokens) is called
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

// Actual token contract implementing ERC20Interface
contract DIOToken is ERC20Interface {
    // Token details
    string public symbol = "DIO";
    string public name = "DIO Coin";
    uint8 public decimals = 2; // Number of decimal places for token units
    uint256 public _totalSupply;

    // Mapping to track balances of each token holder
    mapping(address => uint) balances;

    // Mapping to track allowances allowed by owner to spender
    mapping(address => mapping(address => uint)) allowed;

    // Constructor that gives the creator all initial tokens
    constructor() {
        _totalSupply = 1000000; // Total supply of the tokens
        balances[msg.sender] = _totalSupply; // Allocate all tokens to contract deployer
    }

    // Returns the total token supply
    function totalSupply() public override view returns (uint256) {
        return _totalSupply;
    }

    // Returns the account balance of the `tokenOwner`
    function balanceOf(address tokenOwner) public override view returns (uint256) {
        return balances[tokenOwner];
    }

    // Transfer the balance from caller's account to the `to` address
    function transfer(address to, uint tokens) public override returns (bool success) {
        require(tokens <= balances[msg.sender], "Insufficient balance"); // Check sender's balance

        balances[msg.sender] -= tokens; // Decrease sender's balance
        balances[to] += tokens; // Increase recipient's balance
        emit Transfer(msg.sender, to, tokens); // Emit transfer event
        return true;
    }

    // Approval of `tokens` to be spent by `spender` from caller's account
    function approve(address spender, uint256 tokens) public override returns (bool success) {
        allowed[msg.sender][spender] = tokens; // Set allowance
        emit Approval(msg.sender, spender, tokens); // Emit approval event
        return true;
    }

    // Returns the amount `spender` is allowed to withdraw from `tokenOwner`
    function allowance(address tokenOwner, address spender) public override view returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }

    // Executes transfer of tokens from `from` address to `to` address based on allowance
    function transferFrom(address from, address to, uint256 tokens) public override returns (bool success) {
        require(tokens <= balances[from], "Insufficient balance"); // Check sender's balance
        require(tokens <= allowed[from][msg.sender], "Allowance exceeded"); // Validate transfers within allowances

        balances[from] -= tokens; // Deduct from sender's balance
        allowed[from][msg.sender] -= tokens; // Reduce the amount allowed to transfer
        balances[to] += tokens; // Add to recipient's balance
        emit Transfer(from, to, tokens); // Emit transfer event
        return true;
    }
} 