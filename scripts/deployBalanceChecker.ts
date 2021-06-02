import "@nomiclabs/hardhat-waffle";
import { ethers, waffle } from "hardhat";
const { deployContract } = waffle;

import BalanceCheckerArtifact from "../artifacts/contracts/BalanceChecker.sol/BalanceChecker.json";
import DacFactoryArtifact from "../artifacts/contracts/DacFactory.sol/DacFactory.json";
import DafFactoryArtifact from "../artifacts/contracts/DafFactory.sol/DafFactory.json";

import { DacFactory, DafFactory, BalanceChecker } from "../typechain";

async function main() {
  const signers = await ethers.getSigners();

  const balanceChecker = (await deployContract(
    signers[0],
    BalanceCheckerArtifact
  )) as BalanceChecker;

  console.table({
    balanceChecker: balanceChecker.address,
  });
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
