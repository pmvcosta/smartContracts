import { ethers } from "hardhat";
const assert = require("assert");
import chai from "chai";
import { solidity } from "ethereum-waffle";
import { CampaignFactory } from "../typechain/CampaignFactory";
import { Campaign } from "../typechain/Campaign";
chai.use(solidity);
const { expect } = chai;

describe("CampaignFactory", () => {
  let factory: CampaignFactory;
  //let accounts; //list of all accounts on local ganache network
  //let factory;

  let campaign: Campaign;
  let signers: any;
  let overrides: any;

  beforeEach(async () => {
    // 1
    signers = await ethers.getSigners();
    //console.log(`The type of signers is ${typeof signers}`);

    const factoryFactory = await ethers.getContractFactory(
      "CampaignFactory",
      signers[0]
    );
    factory = (await factoryFactory.deploy()) as CampaignFactory;
    await factory.deployed();

    overrides = {
      from: signers[0].address,
      //gasLimit: 1000000,
    };

    await factory.createCampaign("100", overrides);

    const [campaignAddress] = await factory.getDeployedCampaigns();

    const campaignFactory = await ethers.getContractFactory("Campaign");

    campaign = (await campaignFactory.attach(campaignAddress)) as Campaign;
    await campaign.deployed();

    factory.connect(signers[1]);
    campaign.connect(signers[1]);
  });

  describe("Campaigns", () => {
    it("deploys a factory and a campaign", () => {
      assert.ok(factory.address);
      assert.ok(campaign.address);
    });

    it("marks caller as campaign manager", async () => {
      const manager = await campaign.manager();
      assert.equal(signers[0].address, manager);
    });

    it("allows people to contribute money, marks them as approvers", async () => {
      overrides = {
        //from: signers[1].address,
        value: "200", //minimumContribution is 200 wei
      };

      await campaign.connect(signers[1]).contribute(overrides);

      //approvers is a public variable, thus there is a method to access it
      //entire mapping is not retrieved, can only obtain single values
      const isContributor = await campaign.approvers(signers[1].address);
      assert(isContributor); //fails if isContributor is a falsy value
    });

    it("requires a minimum contribution", async () => {
      try {
        overrides = {
          //from: signers[1].address,//just reconnect contract to new user
          value: "150", //minimumContribution is 200 wei
        };
        await campaign.connect(signers[1]).contribute(overrides);

        assert(false); //so that test fails if condition isnt met
      } catch (err) {
        assert(err);
      }
    });

    it("allows a manager to make a payment request", async () => {
      overrides = {
        from: signers[0].address,
        gasLimit: "1000000",
      };

      await campaign.createRequest(
        "Buy batteries",
        "100",
        signers[1].address,
        overrides
      );

      //requests is a public variable, thus it has an automatic "fetch" method
      //like mappings, can only return a certain index, and its properties
      const request = await campaign.requests(0);

      //Checking one variable should suffice
      assert.equal("Buy batteries", request.description);
    });

    it("processes requests", async () => {
      //Here signers[0] is the manager

      overrides = {
        from: signers[0].address,
        value: ethers.utils.parseEther("10"),
      };
      await campaign.contribute(overrides);

      overrides = {
        from: signers[0].address,
        gasLimit: "1000000",
      };

      await campaign.createRequest(
        "A",
        ethers.utils.parseEther("5"),
        signers[1].address,
        overrides
      );

      //Only one request created, must be at index 0
      overrides = {
        from: signers[0].address,
        gasLimit: "1000000",
      };

      await campaign.approveRequest(0, overrides);

      let iniBalance = await signers[1].getBalance();
      iniBalance = ethers.utils.formatEther(iniBalance);
      iniBalance = parseFloat(iniBalance);
      //console.log(iniBalance);

      overrides = {
        from: signers[0].address,
        gasLimit: "1000000",
      };

      await campaign.finalizeRequest(0, overrides);

      let balance = await signers[1].getBalance();
      balance = ethers.utils.formatEther(balance);
      balance = parseFloat(balance); //Takes a string, tries to turn it into a decimal number
      //console.log(balance);
      assert(balance > iniBalance + 4.9);
    });

    //Test trying to finalize request without enough approval

    //Test trying to use manager-only functions without being the manager
  });
});
