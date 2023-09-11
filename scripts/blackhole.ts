import { ethers } from "hardhat";

async function main() {
	// Get the signer which will host the fees
	const [signer] = await ethers.getSigners();

	// Deploy Blackhole Token
	const ERCFactory = await ethers.getContractFactory("BlackholeToken", signer);
	const TokenContract = await ERCFactory.deploy(
		"Blackhole",
		"BLACK",
		signer.address
	);
	const Black = await TokenContract.deployed();

	// Deploy Universe Factory
	const Factory = await ethers.getContractFactory("UniverseFactory", signer);
	const UniverseContract = await Factory.deploy(Black.address);
	const UniverseFactory = await UniverseContract.deployed();

	// Transfer the ownership
	await Black.transferOwnership(UniverseFactory.address);

	// Log
	console.log("Signer is:", await Black.owner());
	console.log("Blackhole Token deployed to:", Black.address);
	console.log("Universe Factory deployed to:", UniverseFactory.address);
	console.log("Blackhole Token owner is:", await Black.owner());
}

main()
	.then(() => process.exit(0))
	.catch((error) => {
		console.error(error);
		process.exit(1);
	});
