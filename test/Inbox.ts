import { ethers } from "hardhat";
const assert = require("assert");
import chai from "chai";
import { solidity } from "ethereum-waffle";
import { Inbox } from "../typechain/Inbox";
chai.use(solidity);
const { expect } = chai;

describe("Inbox", () => {
  let inbox: Inbox;
  let signers: any;
  let overrides: any;

  beforeEach(async () => {
    signers = await ethers.getSigners();

    const inboxFactory = await ethers.getContractFactory("Inbox", signers[0]);
    inbox = (await inboxFactory.deploy("This is the message")) as Inbox;
    await inbox.deployed();

    //inbox.connect(signers[1]);
  });

  describe("InboxTest", () => {
    it("deploys an Inbox with a message", async () => {
      assert.ok(inbox.address);
      const theMessage = await inbox.message();
      assert.equal(theMessage, "This is the message");
    });

    it("allows user to change the message", async () => {
      await inbox.setMessage("Now the message is this");
      const theMessage = await inbox.message();
      assert.equal(theMessage, "Now the message is this");
    });
  });
});
