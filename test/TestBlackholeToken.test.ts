import { ethers } from "hardhat";
import { expect } from "chai";
import { Contract } from "ethers";

describe("TestERC20", function () {
	let Black: Contract;
	let UniverseFactory: Contract;
	let owner: any;
	let userA: any;
	let userB: any;

	before(async () => {
		[owner, userA, userB] = await ethers.getSigners();

		// Deploy Blackhole Token
		const ERCFactory = await ethers.getContractFactory("BlackholeToken", owner);
		const TokenContract = await ERCFactory.deploy(
			"Blackhole",
			"BLACK",
			owner.address
		);
		Black = await TokenContract.deployed();

		expect(await Black.owner()).to.be.equal(owner.address);

		// Deploy Universe Factory
		const Factory = await ethers.getContractFactory("UniverseFactory", owner);
		const UniverseContract = await Factory.deploy(Black.address);
		UniverseFactory = await UniverseContract.deployed();

		expect(await UniverseFactory.BlackholeToken()).to.be.equal(Black.address);
		expect(await Black.totalSupply()).to.be.equal(0);

		// Transfer the ownership
		await expect(Black.transferOwnership(UniverseFactory.address))
			.to.emit(Black, "OwnershipTransferred")
			.withArgs(owner.address, UniverseFactory.address);

		expect(await Black.owner()).to.be.equal(UniverseFactory.address);

		console.log("Blackhole Token deployed to:", Black.address);
		console.log("Universe Factory deployed to:", UniverseFactory.address);
	});

	it("should Mint BLACK tokens by deleting eth", async () => {
		const value = ethers.utils.parseEther("1");

		await owner.sendTransaction({
			to: UniverseFactory.address,
			value: value,
		});

		expect(await Black.balanceOf(owner.address)).to.be.equal(value);
	});
});
