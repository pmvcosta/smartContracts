//A simple, standard ERC20 token
pragma solidity ^0.8.6;


interface IERC20 {
    //totalSupply - returns the amount of tokens in existence
    function totalSupply() external view returns (uint);

    //balanceOf - returns the number of tokens held by any particular address
    function balanceOf(address tokenOwner) external view returns (uint balance);

    //allowance - Returns the remaining number of tokens that spender will be
    // allowed to spend on behalf of owner through transferFrom.
    // This is zero by default.
    // This value changes when approve or transferFrom are called.
    function allowance(address tokenOwner, address spender) external view returns (uint remaining);

    //transfer - Moves amount tokens from the caller’s account to recipient.
    // Returns a boolean value indicating whether the operation succeeded.
    //Emits a Transfer event.
    function transfer(address to, uint tokens) external returns (bool success);

    //approve - Sets amount as the allowance of spender over the caller’s tokens.
    // Returns a boolean value indicating whether the operation succeeded.
    function approve(address spender, uint tokens) external returns (bool success);

    //transferFrom - Moves amount tokens from sender to recipient using the
    // allowance mechanism. amount is then deducted from the caller’s allowance.
    // Returns a boolean value indicating whether the operation succeeded.
    //Emits a Transfer event.
    function transferFrom(address from, address to, uint tokens) external returns (bool success);


    //These 3 functions are created automatically if the variables
    // holding these parameters are declared as public
    //function symbol() external view returns (string memory);
    //function name() external view returns (string memory);
    //function decimals() external view returns (uint8);

    //Transfer event - used to log the transfer function activity like from
    // account, to account and how many tokens were transferred
    // Emitted when value tokens are moved from one account (from)
    // to another (to).
    //Note that value of tokens may be zero.
    event Transfer(address indexed from, address indexed to, uint tokens);

    //Approval event - Emitted when the allowance of a spender for an
    // owner is set by a call to approve. value is the new allowance.
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

contract ERC20Token is IERC20{
  //ERC20 smart contract code

  mapping(address => uint256) public _balances;

  //Approval
  //e.g.: Account 111 approves account 222 to spend 10 tokens
  // Account 111 allows account 333 to spend 20 tokens
  mapping (address => mapping(address => uint256)) allowed;

  //name, symbol and decimal
  string public name = "TestToken";
  string public symbol = "TTK";

  //This specifies the number of decimal places that a transfer of tokens
  // can have, e.g.: a transfer of 10.23 tokens has decimals = 2
  uint public decimals = 0;

  uint256 public _totalSupply;

  //The address of the creator of the token
  address public _creator;

  constructor()  {
    _creator = msg.sender;
    _totalSupply = 50000;
    _balances[_creator] = _totalSupply;
  }

  //Now we have to implement the functions declared in the interface

  function totalSupply() external override view returns (uint256) {
    return _totalSupply;
  }

  function balanceOf(address tokenOwner) external  override view returns (uint balance){
    return _balances[tokenOwner];
  }

  function transfer(address to, uint tokens) external override returns (bool success){
    //the caller of the function is the "from" account

    //check if the number of tokens is valid
    require( _balances[msg.sender] >= tokens && tokens > 0 && to != msg.sender, "Invalid Transaction" );

    //add to the exisitng value of the recipient
    _balances[to] += tokens;

    //subtract from the sender
    _balances[msg.sender] -= tokens;

    emit Transfer(msg.sender, to, tokens);

    return true; //...

  }


  function allowance(address tokenOwner, address spender) external override view returns (uint remaining){
    //return amount of tokens the owner still allows a given spender to transfer
    return allowed[tokenOwner][ spender];
  }


  function approve(address spender, uint tokens) external override returns (bool success){
    require( _balances[msg.sender] >= tokens && tokens > 0, "Invalid Transaction" );
    allowed[address(msg.sender)][spender] = tokens;

    emit Approval(msg.sender, spender, tokens);
    return true;
  }

  function transferFrom(address from, address to, uint tokens) external override returns (bool success){

    //Additional check required: if amount of tokens is smaller than or equal to the
    // amount allowed
    require( _balances[from] >= tokens && tokens > 0 && allowed[from][to] >= tokens  && to != from, "Invalid Transaction" );


    //add to the exisitng value of the recipient
    _balances[to] += tokens;

    //subtract from the sender
    _balances[from] -= tokens;

    //subtract from allowed amount
    allowed[from][to] -= tokens;

    return true; //...
  }



}
