import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  console.log(`\nCreating plugin repos.`);
  console.warn("TODO: Update this to use the new API");
};
export default func;
func.tags = ["Create_Register_Plugins"];
