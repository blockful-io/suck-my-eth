import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import dotenv from "dotenv";
dotenv.config();

const { PRIVATE_KEY, SEPOLIA_RPC } = process.env;

const config: HardhatUserConfig = {
	solidity: "0.8.20",
	networks: {
		sepolia: {
			url: SEPOLIA_RPC,
			accounts: [`${PRIVATE_KEY}`],
		},
	},
};

export default config;
