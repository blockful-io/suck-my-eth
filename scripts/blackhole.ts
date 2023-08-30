import { ethers } from "hardhat";

async function main() {
	// Get the signer, the Factory bytecode and abi to deploy the contract
	const [signer] = await ethers.getSigners();
	const Factory = await ethers.getContractFactory("UniverseFactory");
	const Universe = await Factory.deploy();
	await Universe.deployed();

	// Create the blackhole contract, call selfdestruct in the same
	// transactions, then get the receipt to fetch events and gas used
	const tx = await Universe.createBlackhole({
		value: ethers.utils.parseEther("1"),
	});
	const receipt = await tx.wait();
}

main()
	.then(() => process.exit(0))
	.catch((error) => {
		console.error(error);
		process.exit(1);
	});
