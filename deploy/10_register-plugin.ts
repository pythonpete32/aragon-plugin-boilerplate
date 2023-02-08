import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { ethers, network } = hre;

  console.log(`\nCreating plugin repos.`);
  console.warn("TODO: Update this to use the new API");

  // const adminReleaseCIDPath = await uploadToIPFS(JSON.stringify(releaseMetadata), network.name);
  // const adminBuildCIDPath = await uploadToIPFS(JSON.stringify(buildMetadata), network.name);
  // await createPluginRepo(
  //   hre,
  //   "admin",
  //   "AdminSetup",
  //   ethers.utils.hexlify(ethers.utils.toUtf8Bytes(`ipfs://${adminReleaseCIDPath}`)),
  //   ethers.utils.hexlify(ethers.utils.toUtf8Bytes(`ipfs://${adminBuildCIDPath}`))
  // );
};
export default func;
func.tags = ["Create_Register_Plugins"];
