import { ethers } from "hardhat";

async function main() {
	// Get the signer, the Factory bytecode and abi to deploy the contract
	const [owner] = await ethers.getSigners();
	const Factory = await ethers.getContractFactory("MatterToken", owner);
	const Contract = await Factory.deploy("MatterToken", "MATTER", owner.address);

	console.log("Owner Address", owner.address);
	console.log("Contract Address", Contract.address);
}

main()
	.then(() => process.exit(0))
	.catch((error) => {
		console.error(error);
		process.exit(1);
	});
