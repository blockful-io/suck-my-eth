import { ethers } from "hardhat";
import { expect } from "chai";
import { Contract } from "ethers";

describe("TestERC20", function () {
	let ERC20: Contract;
	let owner: any;
	let userA: any;
	let userB: any;

	before(async () => {
		[owner, userA, userB] = await ethers.getSigners();
		const Factory = await ethers.getContractFactory("MatterToken", owner);
		const Contract = await Factory.deploy(
			"MatterToken",
			"MATTER",
			owner.address
		);
		ERC20 = await Contract.deployed();

		expect(await ERC20.name()).to.equal("MatterToken");
		expect(await ERC20.symbol()).to.equal("MATTER");
		expect(await ERC20.decimals()).to.equal(18);

		await ERC20.mint(owner.address, 1000);
		await ERC20.mint(userA.address, 1000);
		await ERC20.mint(userB.address, 1000);
	});

	it("should approve 1000 tokens to userA", async () => {
		await ERC20.approve(userA.address, 1000);
		expect(await ERC20.allowance(owner.address, userA.address)).to.equal(1000);
	});

	it("should approve to 0 tokens to userA", async () => {
		await ERC20.approve(userA.address, 0);
		expect(await ERC20.allowance(owner.address, userA.address)).to.equal(0);
	});

	it("should approve to Max Uint256 tokens to userA", async () => {
		await ERC20.approve(userA.address, ethers.constants.MaxUint256);
		expect(await ERC20.allowance(owner.address, userA.address)).to.equal(
			ethers.constants.MaxUint256
		);
	});

	it("should fail to increase userA allowance when at Max Uint256", async () => {
		await ERC20.approve(userA.address, ethers.constants.MaxUint256);
		await expect(ERC20.increaseAllowance(userA.address, 1000)).to.be.rejected;
	});

	it("Should be able to increase allowance of 1000 tokens to userA", async () => {
		await ERC20.approve(userA.address, 0);
		await ERC20.increaseAllowance(userA.address, 1000);
		expect(await ERC20.allowance(owner.address, userA.address)).to.equal(1000);
	});

	it("Should be able to decrease allowance of 1000 tokens to userA", async () => {
		await ERC20.approve(userA.address, 0);
		await ERC20.approve(userA.address, 1000);
		await ERC20.decreaseAllowance(userA.address, 1000);
		expect(await ERC20.allowance(owner.address, userA.address)).to.equal(0);
	});

	it("Should not be able to decrease allowance of 1000 tokens to userA when allowance is 0", async () => {
		await ERC20.approve(userA.address, 0);
		await expect(ERC20.decreaseAllowance(userA.address, 1000)).to.be.rejected;
	});
});
