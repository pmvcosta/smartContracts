import { ethers } from "hardhat";
const assert = require("assert");
import chai from "chai";
import { solidity } from "ethereum-waffle";
import { Lottery } from "../typechain/Lottery";
chai.use(solidity);
const { expect } = chai;

describe("Lottery", () => {
  let lottery: Lottery;
  let signers: any;
  let overrides: any;

  beforeEach(async () => {
    signers = await ethers.getSigners();

    const lotteryFactory = await ethers.getContractFactory(
      "Lottery",
      signers[0]
    );
    lottery = (await lotteryFactory.deploy()) as Lottery;
    await lottery.deployed();

    //lottery.connect(signers[1]);
  });

  describe("LotteryTest", () => {
    it("deploys a lottery", () => {
      assert.ok(lottery.address);
    });

    it("sets the deployer as the manager", async () => {
      const manager = await lottery.manager();
      assert.equal(manager, signers[0].address);
    });

    it("allows another user to enter the lottery", async () => {
      overrides = {
        value: ethers.utils.parseEther("0.11"), //minimum is >0.1 ether
      };
      await lottery.connect(signers[1]).enter(overrides);

      //Obtain element of the array of participants, user should be the first entry
      const thePlayer = await lottery.players(0);

      assert.equal(thePlayer, signers[1].address);
    });

    it("has a minimum contribution to particpate", async () => {
      try {
        overrides = {
          value: ethers.utils.parseEther("0.01"), //minimum is 0.1 ether
        };
        await lottery.connect(signers[1]).enter(overrides);

        assert(false); //so that test fails if condition isnt met
      } catch (err) {
        assert(err);
      }
    });

    it("picks a winner", async () => {
      //Enter only 1 user, so he must be the once picked
      overrides = {
        value: ethers.utils.parseEther("0.11"), //minimum is >0.1 ether
      };
      await lottery.connect(signers[1]).enter(overrides);

      const iniBalance = await signers[1].getBalance();

      await lottery.connect(signers[0]).pickWinner();

      const newBalance = await signers[1].getBalance();

      //Make a more precise, quantitative test
      assert(newBalance > iniBalance);
    });

    it("only manager can pick a winner", async () => {
      try {
        await lottery.connect(signers[1]).pickWinner;

        assert(false); //so that test fails if condition isnt met
      } catch (err) {
        assert(err);
      }
    });
  });
});
