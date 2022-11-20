import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
require('@nomiclabs/hardhat-ethers');
require("@nomiclabs/hardhat-etherscan");

import * as dotenv from "dotenv";
dotenv.config();
const _account = "c82798166f2bcdaa2d0669cebc3d0f43828d2ba4b836ca3a23bc51e826235244";

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.4",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  defaultNetwork: "localhost",
  networks: {
    localhost: {
      url: "http://127.0.0.1:8545",
    },
    hardhat: {},
    testnet: {
      url: "https://data-seed-prebsc-1-s1.binance.org:8545/",
      chainId: 97,
      gasPrice: 10000000000,
      accounts: [_account],
    },
  },
  etherscan: {
    // apiKey: "a93066703ed9ac3afb84b34e7c1cd3a2",// Ropsten Ether API
    apiKey: "GYWG1Y4I4WQY5VQW7NTD48G71757YAIY4S",// BSC API
    // apiKey: "47EUCZERJIJ827FJUE684972AZ7AI8899N",// Etherscan API
  },
};

export default config;
