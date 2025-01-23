pragma solidity ^0.4.24;

// This contract provides basic mathematical operations with safety checks
contract SafeMath {

    // Adds two numbers, reverts on overflow
    function safeAdd(uint a, uint b) public pure returns (uint c) {
        c = a + b;
        require(c >= a); // Ensure the value has not overflowed
    }
 
    // Subtracts two numbers, reverts on underflow
    function safeSub(uint a, uint b) public pure returns (uint c) {
        require(b <= a); // Ensure there is no underflow
        c = a - b;
    }
 
    // Multiplies two numbers, reverts on overflow
    function safeMul(uint a, uint b) public pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b); // Ensure the result is correct
    }
 
    // Divides two numbers, reverts on division by zero
    function safeDiv(uint a, uint b) public pure returns (uint c) {
        require(b > 0); // Prevent division by zero
        c = a / b;
    }
}

// ERC Token Standard #20 Interface
// Defines the essential token functions needed for an ERC20 token
contract ERC20Interface {
    function totalSupply() public constant returns (uint);
    function balanceOf(address tokenOwner) public constant returns (uint balance);
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    // Events to capture approvals and transfers
    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

// Contract function to receive approval and execute function call in one transaction
contract ApproveAndCallFallBack {
    function receiveApproval(address from, uint256 tokens, address token, bytes data) public;
}

// Actual token contract implementing ERC20 and SafeMath
contract DIOToken is ERC20Interface, SafeMath {
    string public symbol; // Token symbol
    string public name; // Token name
    uint8 public decimals; // How many decimal places the token uses
    uint public _totalSupply; // Total supply of tokens available

    // MetaMask wallet address where initial tokens are allocated
    address private constant YOUR_METAMASK_WALLET_ADDRESS = 0xCc33B13D641503BF99F60Eb4c24C723B50191790;

    // Balance mappings
    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;

    // Constructor to assign the initial token supply to MetaMask wallet
    constructor() public {
        symbol = "DIO";
        name = "DIO Coin";
        decimals = 2;
        _totalSupply = 100000;
        balances[YOUR_METAMASK_WALLET_ADDRESS] = _totalSupply;
        emit Transfer(address(0), YOUR_METAMASK_WALLET_ADDRESS, _totalSupply); // Emit transfer event from zero address for minting
    }

    // Returns total supply of tokens, excluding tokens in the zero address
    function totalSupply() public constant returns (uint) {
        return _totalSupply - balances[address(0)];
    }

    // Get the token balance for account `tokenOwner`
    function balanceOf(address tokenOwner) public constant returns (uint balance) {
        return balances[tokenOwner];
    }

    // Transfer `tokens` from the caller to the address `to`
    function transfer(address to, uint tokens) public returns (bool success) {
        balances[msg.sender] = safeSub(balances[msg.sender], tokens); // Deduct tokens from sender
        balances[to] = safeAdd(balances[to], tokens); // Add tokens to receiver
        emit Transfer(msg.sender, to, tokens); // Emit transfer event
        return true;
    }

    // Approve `spender` to withdraw `tokens` from caller's account
    function approve(address spender, uint tokens) public returns (bool success) {
        allowed[msg.sender][spender] = tokens; // Record allowance
        emit Approval(msg.sender, spender, tokens); // Emit approval event
        return true;
    }

    // Transfer `tokens` from `from` to `to` if the caller is allowed
    function transferFrom(address from, address to, uint tokens) public returns (bool success) {
        balances[from] = safeSub(balances[from], tokens); // Deduct tokens from source
        allowed[from][msg.sender] = safeSub(allowed[from][msg.sender], tokens); // Reduce allowance
        balances[to] = safeAdd(balances[to], tokens); // Add tokens to destination
        emit Transfer(from, to, tokens); // Emit transfer event
        return true;
    }

    // Returns the amount `spender` is allowed to transfer from `tokenOwner`
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }

    // Approve `spender` to withdraw `tokens` from caller and call receiveApproval in one step
    function approveAndCall(address spender, uint tokens, bytes data) public returns (bool success) {
        allowed[msg.sender][spender] = tokens; // Set allowance
        emit Approval(msg.sender, spender, tokens); // Emit approval event
        ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, this, data); // Execute external call
        return true;
    }

    // Fallback function, prevents sending ETH to this contract
    function () public payable {
        revert(); // Revert any ether sent mistakenly
    }
}