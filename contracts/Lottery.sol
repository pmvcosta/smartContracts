pragma solidity ^0.8.6;

contract Lottery{
  address public manager;
  address payable[]  public players;

  constructor() {
    manager = msg.sender;
  }

  /*constructor() public{

  }*/

  function enter() public payable {
    require(msg.value > .01 ether );//Used for validation
    // ether converts .01 Ether into its value in wei
    //In Solidity 0.8 msg.sender is not automatically payable anymore.
    // So you need to make it payable first:
    players.push(payable(msg.sender));
  }

  function pickWinner() public restricted {
    //Only manager can call this function
    //require(msg.sender == manager);
    //index of the winning player
    uint index = random() % players.length;
    //transfer ether contained within contract to winner
    players[index].transfer(address(this).balance);
    //create new dynamic array of type address with 0 length (hence the (0) )
    players = new address payable[](0);
  }

  //Helper function, doesn't alter data, returns pseudo-random positive integer
  function random() private view returns(uint){
    //"sha3" has been deprecated in favour of "keccak256".
    //"now" has been deprecated. Use "block.timestamp" instead.
    return uint(keccak256(abi.encode(block.difficulty, block.timestamp, players)));//evoke the sha3
  }

  modifier restricted() {
    require(msg.sender == manager);
    _;
  }

  function getPlayers() public view returns (address payable[] memory){
    return players;
  }
}
