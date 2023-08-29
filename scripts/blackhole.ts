import { ethers } from "hardhat";

async function main() {
	const [signer] = await ethers.getSigners();
	const Factory = await ethers.deployContract("Blackhole");
	const Blackhole = await Factory.waitForDeployment();
	const address = await Blackhole.getAddress();

	console.log("\nBlackhole deployed to:", address);

	const balance0x = await ethers.provider.getBalance(ethers.ZeroAddress);

	console.log("\nBalance of:");
	console.log("Zero Address: ", ethers.formatEther(balance0x));
	console.log("Signer: ", ethers.formatEther(signer.address));

	const balanceBlackhole = await ethers.provider.getBalance(address);
	console.log("Blackhole: ", ethers.formatEther(balanceBlackhole));

	console.log("---------end---------");
}

main()
	.then(() => process.exit(0))
	.catch((error) => {});
