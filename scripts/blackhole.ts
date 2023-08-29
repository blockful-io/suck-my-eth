import { ethers } from "hardhat";

async function main() {
	// Get the signer, the Factory bytecode and abi to deploy the contract
	const [signer] = await ethers.getSigners();
	const Factory = await ethers.getContractFactory("UniverseFactory");
	const Universe = await Factory.deploy();
	await Universe.deployed();

	// Get the balance of the Zero Address, the signer and the Factory
	var balance0xBefore = await ethers.provider.getBalance(
		ethers.constants.AddressZero
	);
	var balanceSinerBefore = await ethers.provider.getBalance(signer.address);
	var balanceFactoryBefore = await ethers.provider.getBalance(Universe.address);

	// Create the blackhole contract, call selfdestruct in the same
	// transactions, then get the receipt to fetch events and gas used
	const tx = await Universe.createBlackhole({
		value: ethers.utils.parseEther("1"),
	});
	const receipt = await tx.wait();

	// Get the events - using `?` was not avoiding the error and my ADHD kiked
	// @ts-ignore
	const blackholeAddress = receipt.events[0].args[0];
	// @ts-ignore
	const blackholeSucked = receipt.events[0].args[1];

	// Get the balance once more to compare
	var balance0xAfter = await ethers.provider.getBalance(
		ethers.constants.AddressZero
	);
	var balanceSinerAfter = await ethers.provider.getBalance(signer.address);
	var balanceFactoryAfter = await ethers.provider.getBalance(Universe.address);

	// We emited an event with the blackhole address, meaning we ca
	// fetch the balance of the blackhole contract and the eth sucked
	var balanceBlackhole = await ethers.provider.getBalance(blackholeAddress);

	// Print the results
	console.log("\nBlackhole Factory deployed to:", Universe.address);
	console.log("---------------------");
	console.log("\nBalance before:");
	console.log("Zero Address: ", ethers.utils.formatEther(balance0xBefore));
	console.log("Signer: ", ethers.utils.formatEther(balanceSinerBefore));
	console.log("Factory: ", ethers.utils.formatEther(balanceFactoryBefore));
	console.log("---------------------");
	console.log("Balance after:");
	console.log("Zero Address: ", ethers.utils.formatEther(balance0xAfter));
	console.log("Signer: ", ethers.utils.formatEther(balanceSinerAfter));
	console.log("Factory: ", ethers.utils.formatEther(balanceFactoryAfter));
	console.log("Blackhole: ", ethers.utils.formatEther(balanceBlackhole));
	console.log("---------------------");
	console.log("Blackhole address: ", blackholeAddress);
	console.log(
		"Blackhole eth amount sucked: ",
		ethers.utils.formatEther(blackholeSucked)
	);
	console.log("Gas used: ", receipt.gasUsed.toString());
	console.log("The Eth is deleted forever");
	console.log("---------------------");
}

main()
	.then(() => process.exit(0))
	.catch((error) => {
		console.error(error);
		process.exit(1);
	});
