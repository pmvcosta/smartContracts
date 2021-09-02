pragma solidity ^0.4.17;

contract Lottery{
  address public manager;
  address[] public players;

  function Lottery() public{
    manager = msg.sender;
  }

  /*constructor() public{

  }*/

  function enter() public payable {
    require(msg.value > .01 ether );//Used for validation
    // ether converts .01 Ether into its value in wei
    players.push(msg.sender);
  }

  function pickWinner() public restricted {
    //Only manager can call this function
    //require(msg.sender == manager);
    //index of the winning player
    uint index = random() % players.length;
    //transfer ether contained within contract to winner
    players[index].transfer(this.balance);
    //create new dynamic array of type address with 0 length (hence the (0) )
    players = new address[](0);
  }

  //Helper function, doesn't alter data, returns pseudo-random positive integer
  function random() private view returns(uint){
    return uint(sha3(block.difficulty, now, players));//evoke the sha3
  }

  modifier restricted() {
    require(msg.sender == manager);
    _;
  }

  function getPlayers() public view returns (address[]){
    return players;
  }
}
