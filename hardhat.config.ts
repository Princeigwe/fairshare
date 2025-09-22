import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import dotenv from "dotenv";

dotenv.config();

const config: HardhatUserConfig = {
  solidity: "0.8.28",
  paths: {
    artifacts: "./artifacts"
  },
  networks: {
    'base-sepolia': {
      url: 'https://sepolia.base.org',
      accounts: [process.env.WALLET_PRIVATE_KEY as string]
    }
  },
  etherscan: {
    apiKey: process.env.FAIRSHARE_SEPOLIA_ETHERSCAN_API_KEY,
  },
};

export default config;
