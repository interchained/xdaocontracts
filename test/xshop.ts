import "@nomiclabs/hardhat-waffle";
import { ethers, waffle } from "hardhat";

import XShopArtifact from "../artifacts/contracts/XShop.sol/XShop.json";
import DacArtifact from "../artifacts/contracts/Dac.sol/Dac.json";
import { Dac, XShop } from "../typechain";

import { expect } from "chai";
import { BigNumber } from "@ethersproject/bignumber";
import { parseEther } from "@ethersproject/units";

const { deployContract } = waffle;

const WBNB = "0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c";

describe("XShop", () => {
  let dac: Dac;

  let xshop: XShop;

  let abiCoder = new ethers.utils.AbiCoder();

  beforeEach(async () => {
    const signers = await ethers.getSigners();

    const myAddress = await signers[0].getAddress();

    const dacInfo = {
      name: "EgorDac",
      symbol: "EDAC",
      currency: WBNB,
      teammates: [myAddress],
      totalSupply: 100e3,
      governanceTokensPrice: BigNumber.from(+"1e16" + ""),
      purchasePublic: false,
      halfToVote: false,
      votingDuration: 7200,
    };

    dac = (await deployContract(signers[0], DacArtifact, [
      dacInfo.name,
      dacInfo.symbol,
      dacInfo.currency,
      dacInfo.teammates,
      dacInfo.totalSupply,
      dacInfo.governanceTokensPrice,
      dacInfo.purchasePublic,
      dacInfo.halfToVote,
      dacInfo.votingDuration,
    ])) as Dac;

    xshop = (await deployContract(signers[0], XShopArtifact, [
      dac.address,
    ])) as XShop;
  });

  it("Shows Info Well", async () => {
    expect(await xshop.daoAddress()).to.equal(dac.address);
    expect(await xshop.daoCurrency()).to.equal(WBNB);
  });

  it("Full Test", async () => {
    const provider = ethers.provider;

    const signers = await ethers.getSigners();

    expect(await xshop.getOffers()).to.be.empty;

    const friendAddress = await signers[1].getAddress();

    await dac.createVoting(
      xshop.address,
      ethers.utils.id("createOffer(address,uint256,uint256)").slice(0, 10) +
        abiCoder
          .encode(
            ["address", "uint256", "uint256"],
            [friendAddress, 1, parseEther("0.01")]
          )
          .slice(2),
      0,
      "Sell to friend"
    );

    await dac.signVoting(0);

    await dac.activateVoting(0);

    expect((await xshop.getOffers()).length).to.equal(1);

    expect((await xshop.offers(0)).recipient).to.equal(friendAddress);

    await dac.createVoting(
      dac.address,
      ethers.utils.id("approve(address,uint256)").slice(0, 10) +
        abiCoder.encode(["address", "uint256"], [xshop.address, 1]).slice(2),
      0,
      "Sell to friend"
    );

    await dac.signVoting(1);

    await dac.activateVoting(1);

    expect(await dac.balanceOf(friendAddress)).to.equal(0);

    expect(await dac.balanceOf(dac.address)).to.equal(100e3);

    expect(await provider.getBalance(dac.address)).to.equal(0);

    expect(await provider.getBalance(xshop.address)).to.equal(0);

    await xshop.connect(signers[1]).getGovernanceTokens(0, {
      value: parseEther("0.01"),
    });

    expect(await dac.balanceOf(friendAddress)).to.equal(1);

    expect(await dac.balanceOf(dac.address)).to.equal(100e3 - 1);

    expect(await provider.getBalance(dac.address)).to.equal(0);

    expect(await provider.getBalance(xshop.address)).to.equal(
      parseEther("0.01")
    );

    await dac.createVoting(
      xshop.address,
      ethers.utils.id("releaseCoins()").slice(0, 10),
      0,
      "Release Coins"
    );

    await dac.signVoting(2);

    await dac.activateVoting(2);

    expect(await provider.getBalance(xshop.address)).to.equal(0);

    expect(await provider.getBalance(dac.address)).to.equal(parseEther("0.01"));
  });
});
