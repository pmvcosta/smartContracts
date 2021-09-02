This is the place where I store the Ethereum smart contracts I develop as I learn new concepts and applications of this awesome technology.

As I am working wiht Ethereum, the main language used here is Solidity. In the future, I will create additional projects where I also create a ReactJS frontend to interact with these smart contracts (It really is quite exciting!).

Currently, the smart contracts contained within this repository are:

- `Inbox.sol`: pretty much as basic as a smart contract gets, only storing a message that can be fetched and altered according to the inputs provided;

- `Lottery.sol`: a ever-so-slightly more complex smart contract that allows several users to join a lottery by paying a fixed fee. The accumulated fees make up the reward pool, whose value is then randomly given to one of the participants whenever the creator of the contract wishes to do so;

- `Campaign.sol`: this is still to a great extent a work in progress, but its main purpouse to create "funding campaigns" similar to those present in crowdfunding websites, but using ETH transfers instead of other more conventional means of contributing. Also allows for investors to create requests that can then be voted on, and finalized by the creator of the contract. Still need to add fields to include the name of the campaign, the funding goal, perhaps a description of the project, and a few other parameters. Still, it works nicely with regards to its current elements.

In the future, I plan to create contracts delving into the creation of tokens (likely ERC20 tokens, given their popularity) and contracts to carry out ICOs. These aren't the only contracts I aim to create, but they represent the key concepts I want to explore first :) .
