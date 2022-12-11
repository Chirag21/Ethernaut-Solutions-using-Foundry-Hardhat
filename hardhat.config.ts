require("dotenv").config();
import fs from "fs";
import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "hardhat-preprocessor";
import "@openzeppelin/hardhat-upgrades";
import "@nomicfoundation/hardhat-chai-matchers";
import "hardhat-contract-sizer";

export const PRIVATE_KEY = process.env.PRIVATE_KEY;
export const ANVIL_PRIVATE_KEY = process.env.ANVIL_PRIVATE_KEY;
export const POLYGON_TESTNET_RPC_URL = process.env.POLYGON_TESTNET_RPC_URL || "https://rpc.ankr.com/polygon_mumbai";
export const BLOCK_EXPLORER_URL = "https://mumbai.polygonscan.com/tx";
export const devNetworks = ["localhost", "hardhat"];

function getRemappings() {
  return fs
    .readFileSync("remappings.txt", "utf8")
    .split("\n")
    .filter(Boolean)
    .map((line) => line.trim().split("="));
}
const config: HardhatUserConfig = {
  solidity: {
    compilers: [
      {
        version: "0.5.3",
        settings: {
          optimizer: {
            enabled: false,
            runs: 1000,
          },
        },
      },
      {
        version: "0.6.12",
        settings: {
          optimizer: {
            enabled: false,
            runs: 1000,
          },
        },
      },
      {
        version: "0.8.17",
        settings: {
          optimizer: {
            enabled: false,
            runs: 1000,
          },
        },
      },
    ],
  },
  paths: {
    sources: "src", // Use ./src rather than ./contracts as Hardhat expects
    cache: "cache_hardhat", // Use a different cache for Hardhat than Foundry
    tests: "test/hardhat",
  },
  // This fully resolves paths for imports in the ./lib directory for Hardhat
  preprocess: {
    eachLine: (hre) => ({
      transform: (line: string) => {
        if (line.match(/^\s*import /i)) {
          getRemappings().forEach(([find, replace]) => {
            if (line.match(find)) {
              line = line.replace(find, replace);
            }
          });
        }
        return line;
      },
    }),
  },
  networks: {
    hardhat: {
      chainId: 1337,
      forking: {
        url: POLYGON_TESTNET_RPC_URL,
        enabled: true,
        blockNumber: 29385384,
      },
      loggingEnabled: true,
    },
    localhost: {
      chainId: 1337,
      loggingEnabled: true,
      forking: {
        url: POLYGON_TESTNET_RPC_URL,
        enabled: false,
        blockNumber: 29385384,
      },
    },
    mumbai: {
      chainId: 80001,
      url: POLYGON_TESTNET_RPC_URL,
      accounts: PRIVATE_KEY !== undefined ? [PRIVATE_KEY] : [],
      loggingEnabled: true,
    },
    anvil: {
      chainId: 169,
      url: "http://127.0.0.1:8545/",
      accounts: ANVIL_PRIVATE_KEY !== undefined ? [ANVIL_PRIVATE_KEY] : [],

      loggingEnabled: true,
    },
  },
  defaultNetwork: "hardhat",
};

export default config;
