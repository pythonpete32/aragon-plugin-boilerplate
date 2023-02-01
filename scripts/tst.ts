import hre from "hardhat";
import { activeContractsList } from "@aragon/core-contracts-ethers";

console.log(hre.network.name);
console.log(activeContractsList[hre.network.name]);
