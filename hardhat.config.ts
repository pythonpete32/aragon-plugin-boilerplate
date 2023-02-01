import * as dotenv from "dotenv";
import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "hardhat-deploy";

dotenv.config();

const config: HardhatUserConfig = {
  solidity: "0.8.17",
  networks: {
    goerli: {
      url: process.env.GOERLI_RPC_URL,
      accounts: {
        mnemonic: process.env.MNEMONIC as string,
      },
    },
    frame: {
      httpHeaders: { origin: "hardhat" },
      url: "http://localhost:1248",
    },
  },
  namedAccounts: {
    deployer: 0,
  },
};

export default config;
