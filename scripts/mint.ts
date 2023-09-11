import { ethers } from "hardhat";

async function main() {
	// Get the signer which will host the fees
	const [signer] = await ethers.getSigners();

	// Get the Universe factory contract
	const UniverseFactory = "0xFf0A6fAcabf046B3CB25FbD75d1E18ccC4B0d4B5";

	// Send Eth to mint $BLACK
	const tx = await signer.sendTransaction({
		to: UniverseFactory,
		value: ethers.utils.parseEther("0.004"),
	});

	console.log("Transaction hash:", tx.hash);
}

main()
	.then(() => process.exit(0))
	.catch((error) => {
		console.error(error);
		process.exit(1);
	});
