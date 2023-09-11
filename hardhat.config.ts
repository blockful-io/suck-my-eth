import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import dotenv from "dotenv";
dotenv.config();

const { PRIVATE_KEY, SEPOLIA_RPC, ETHERSCAN_API_KEY } = process.env;

const config: HardhatUserConfig = {
	solidity: "0.8.20",
	// gasReporter: {
	// 	enabled: true,
	// },
	etherscan: {
		// apiKey: ETHERSCAN_API_KEY,
	},
	networks: {
		// sepolia: {
		// 	url: SEPOLIA_RPC,
		// 	accounts: [`${PRIVATE_KEY}`],
		// },
	},
};

export default config;
