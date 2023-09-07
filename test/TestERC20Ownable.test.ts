import { ethers } from "hardhat";
import { expect } from "chai";
import { Contract } from "ethers";

describe("ERC20-Ownable", function () {
	let ERC20: Contract;
	let owner: any;
	let userA: any;
	let userB: any;

	before(async () => {
		[owner, userA, userB] = await ethers.getSigners();
		const Factory = await ethers.getContractFactory("BlackholeToken", owner);
		const Contract = await Factory.deploy("Blackhole", "BLACK", owner.address);
		ERC20 = await Contract.deployed();

		expect(await ERC20.name()).to.equal("Blackhole");
		expect(await ERC20.symbol()).to.equal("BLACK");
		expect(await ERC20.decimals()).to.equal(18);
	});

	it("should have the correct owner", async function () {
		expect(await ERC20.owner()).to.equal(owner.address);
	});

	it("should transfer owner correctly", async function () {
		await ERC20.connect(owner).transferOwnership(userA.address);
		expect(await ERC20.owner()).to.equal(userA.address);
	});

	it("should not be able to transfer owner if not owner", async function () {
		await expect(
			ERC20.connect(userB).transferOwnership(userB.address)
		).to.be.revertedWithCustomError(ERC20, "OwnableUnauthorizedAccount");
	});
});
