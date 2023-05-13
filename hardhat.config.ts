require("dotenv").config();
import "@nomicfoundation/hardhat-chai-matchers";
import "@nomicfoundation/hardhat-toolbox";
import "@openzeppelin/hardhat-upgrades";
import fs from "fs";
import "hardhat-contract-sizer";
import "hardhat-preprocessor";
import { HardhatUserConfig } from "hardhat/config";

export const TESTNET_PRIVATE_KEY_1 = process.env.TESTNET_PRIVATE_KEY_1!;
export const TESTNET_PRIVATE_KEY_2 = process.env.TESTNET_PRIVATE_KEY_2!;
export const ANVIL_PRIVATE_KEY_1 = process.env.ANVIL_PRIVATE_KEY_1!;
export const ANVIL_PRIVATE_KEY_2 = process.env.ANVIL_PRIVATE_KEY_2!;
export const ANVIL_PRIVATE_KEY_3 = process.env.ANVIL_PRIVATE_KEY_3!;
export const POLYGON_TESTNET_RPC_URL = process.env.POLYGON_TESTNET_RPC_URL || "https://rpc.ankr.com/polygon_mumbai";
export const BLOCK_EXPLORER_URL = process.env.BLOCK_EXPLORER_URL;
export const developmentNetworks = ["anvil", "localhost", "hardhat"];

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
        version: "0.5.17",
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
        version: "0.7.6",
        settings: {
          optimizer: {
            enabled: false,
            runs: 1000,
          },
        },
      },
      {
        version: "0.8.20",
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
        enabled: false,
        // blockNumber: ,
      },
      loggingEnabled: true,
    },
    localhost: {
      chainId: 1337,
      loggingEnabled: true,
      // forking: {
      //   url: POLYGON_TESTNET_RPC_URL,
      //   enabled: false,
      //   blockNumber: 29385384,
      // },
    },
    mumbai: {
      chainId: 80001,
      url: POLYGON_TESTNET_RPC_URL,
      accounts: [TESTNET_PRIVATE_KEY_1, TESTNET_PRIVATE_KEY_2],
      loggingEnabled: true,
    },
    anvil: {
      chainId: 169,
      url: "http://127.0.0.1:8545/",
      accounts: [ANVIL_PRIVATE_KEY_1, ANVIL_PRIVATE_KEY_2, ANVIL_PRIVATE_KEY_3],
      loggingEnabled: true,
    },
  },
  defaultNetwork: "hardhat",

  // Hardhat gas Reporter
  gasReporter: {
    enabled: process.env.REPORT_GAS ? true : false,
  },
};

export default config;
