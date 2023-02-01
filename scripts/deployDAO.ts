import hre, { ethers } from "hardhat";

import { DAOFactory__factory, activeContractsList } from "@aragon/core-contracts-ethers";
import { LensVotingSetup } from "../typechain-types/contracts/LensVotingSetup";
const BN = ethers.BigNumber.from;
const abiCoder = new ethers.utils.AbiCoder();

const FIFTY_PERCENT = BN("500000000000000000");
const FIVE_PERCENT = BN("50000000000000000");
const ONE_DAY = 60 * 60 * 24;
const ZERO_ADDRESS = "0x0000000000000000000000000000000000000000";
const NFT = "0x5f365D15af4Fe62839dAd2371AAe3a858A283DB9";

const lensVotingRepo = ZERO_ADDRESS;

async function main() {
  const signers = await ethers.getSigners();
  const signer = signers[0];
  const daoFactoryInstance = DAOFactory__factory.connect(
    activeContractsList[hre.network.name]["DAOFactory"],
    signer
  );

  const LensVotingSetup = await hre.deployments.get("LensVotingSetup");
  const daoSettings: any = [ZERO_ADDRESS, "TestDAO00000123123", "0x00"];

  const initData = abiCoder.encode(
    ["uint64", "uint64", "uint64", "tuple(address addr, string name, string symbol)"],
    [FIVE_PERCENT, FIFTY_PERCENT, ONE_DAY, [NFT, "Lens Voting Token", "LVT"]]
  );

  daoFactoryInstance.createDao(daoSettings, [
    {
      pluginSetup: LensVotingSetup.address,
      pluginSetupRepo: "0x83d3Dc41E691C101B194a31814D6d0672697E7d7",
      data: initData,
    },
  ]);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
