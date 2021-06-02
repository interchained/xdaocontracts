import "@nomiclabs/hardhat-waffle";
import { ethers, waffle } from "hardhat";
const { deployContract } = waffle;

import DacFactoryArtifact from "../artifacts/contracts/DacFactory.sol/DacFactory.json";
import DafFactoryArtifact from "../artifacts/contracts/DafFactory.sol/DafFactory.json";

import { DacFactory, DafFactory } from "../typechain";

async function main() {
  const signers = await ethers.getSigners();

  const dacFactory = (await deployContract(signers[0], DacFactoryArtifact, [
    [
      "0x7ceB23fD6bC0adD59E62ac25578270cFf1b9f619", //  ETH
      "0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174", //  USDC
      "0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270", //  MATIC
      "0xc2132D05D31c914a87C6611C10748AEb04B58e8F", //  USDT
      "0x8f3Cf7ad23Cd3CaDbD9735AFf958023239c6A063", //  DAI
      "0x2e2DDe47952b9c7deFDE7424d00dD2341AD927Ca", //  CHUM
    ],
  ])) as DacFactory;

  const dafFactory = (await deployContract(signers[0], DafFactoryArtifact, [
    [
      "0x7ceB23fD6bC0adD59E62ac25578270cFf1b9f619", //  ETH
      "0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174", //  USDC
      "0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270", //  MATIC
      "0xc2132D05D31c914a87C6611C10748AEb04B58e8F", //  USDT
      "0x8f3Cf7ad23Cd3CaDbD9735AFf958023239c6A063", //  DAI
      "0x2e2DDe47952b9c7deFDE7424d00dD2341AD927Ca", //  CHUM
    ],
  ])) as DafFactory;

  console.table({
    dacFactory: dacFactory.address,
    dafFactory: dafFactory.address,
  });
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
