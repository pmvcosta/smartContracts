pragma solidity ^0.8.6;

contract CampaignFactory{
  address[] public deployedCampaigns;

  function createCampaign (uint minimum) public {
    //minimum is the minimum contribution expected by a campaign
    address newCampaign = new Campaign(minimum, msg.sender);
    //like this ^, sender will be the factory contract
    deployedCampaigns.push(newCampaign);

  }

  function getDeployedCampaigns () public view returns (address[]) {
    return deployedCampaigns;
  }
}

contract Campaign{
  //This is a struct definition, not a variable, still needs to be instanciated
  struct Request {
    string description;
    uint value;
    address recipient;
    bool complete;
    mapping(address => bool) approvals;//Keeping track of who has voted
    uint approvalCount;//Number of approvals, to be compared with numver of approvers (defined below)
  }
  //approvals doesn't have to be initialized,
  //it is not a value type, it is a reference type
  address public manager;
  uint public minimumContribution;
  uint public approversCount;
  mapping(address => bool) public approvers;
  //address[] public approvers;
  //Creating an array of Request instances
  Request[] public requests;

  modifier restricted() {
    require(msg.sender == manager);
    _;
  }

  // Minimum contribution is bound to vary from case to case
  function Campaign(uint minimum, address creator) public {
    manager = creator;
    minimumContribution = minimum;
  }

  //Users will send a contribution, hence the payable modifier
  function contribute() public payable {
    //Check if person has sent minimum contribution or more
    require(msg.value > minimumContribution);
    //if person contributes enough, they qualify as an approver
    //approvers.push(msg.sender);//Only valid for arrays
    approvers[msg.sender] = true;//adds new key, gives it the value of true
    //value of msg.sender isn't stored in mapping
    approversCount++;
    //Keep count of approvers
  }

  function createRequest( string description, uint value, address recipient ) public restricted {
    //Only manager can access this function
    //Whenever an instance of a struct is created we must provide
    //as many arguments as were defined above
    Request memory newRequest = Request({
      description : description,
      value : value,
      recipient : recipient,
      complete : false,
      approvalCount: 0 //approvals doesn't have to be initialized,
      //it is not a value type, it is a reference type
    });
    requests.push(newRequest);
  }

//index of the request being approved (or not) is an argument
  function approveRequest( uint index) public{
    //Instead of always calling requests[index], pass a reference, dont make a copy
    Request storage request = requests[index];
    //Check if person has contributed above minimum amount
    require(approvers[msg.sender]);//Checks if value in mapping is true
    //"!" is used as a "not"
    require(!request.approvals[msg.sender]);
    request.approvals[msg.sender] = true;
    request.approvalCount++;

  }

  function finalizeRequest(uint index) public restricted {
    //Only manager can access this function
    Request storage request = requests[index];
    require(request.approvalCount > (approversCount /2));
    require(!request.complete);//Check if request isn't complete already
    request.recipient.transfer(request.value);
    request.complete = true;
    //Decide if a request has had enough approval
    //At least 50% voted "yes"<--condition to finalize
  }

  function getSummary() public view returns (
    uint, uint, uint, uint, address
   ) {
    //Return campaign balance, minimum contribution, number of requests
    return(
      minimumContribution,
      this.balance, //this is deprecated, use address(this).balance
      requests.length,
      approversCount,
      manager
    );
  }

  function getRequestsCount() public view returns (uint) {
    return requests.length;
  }

}
