import "@nomiclabs/hardhat-waffle";
import { ethers, waffle } from "hardhat";

import DaoViewerArtifact from "../artifacts/contracts/DaoViewer.sol/DaoViewer.json";

import { DaoViewer } from "../typechain/DaoViewer";

const { deployContract } = waffle;

async function main() {
  const signers = await ethers.getSigners();

  const daoViewer = (await deployContract(
    signers[0],
    DaoViewerArtifact
  )) as DaoViewer;

  console.log(daoViewer.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
