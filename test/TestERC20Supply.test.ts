import { ethers } from "hardhat";
import { expect } from "chai";
import { Contract } from "ethers";

describe("ERC20-Supply", function () {
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
	});

	it("should mint 1000 tokens to owner", async () => {
		const mintAmount = 1000;
		const totalSupply = await ERC20.connect(owner).totalSupply();

		await ERC20.connect(owner).mint(owner.address, mintAmount);

		expect(await ERC20.connect(owner).totalSupply()).to.equal(
			Number(totalSupply) + mintAmount
		);
		expect(await ERC20.balanceOf(owner.address)).to.equal(mintAmount);
	});

	it("should mint 1000 tokens to zero address", async () => {
		const mintAmount = 1000;
		const totalSupply = await ERC20.connect(owner).totalSupply();

		await ERC20.connect(owner).mint(ethers.constants.AddressZero, mintAmount);

		expect(await ERC20.connect(owner).totalSupply()).to.equal(
			Number(totalSupply) + mintAmount
		);
		expect(await ERC20.balanceOf(ethers.constants.AddressZero)).to.equal(
			mintAmount
		);
	});

	it("should mint 0 tokens to zero address and not affect anything", async () => {
		const mintAmount = 0;
		const totalSupply = await ERC20.connect(owner).totalSupply();

		await ERC20.connect(owner).mint(ethers.constants.AddressZero, mintAmount);

		expect(await ERC20.connect(owner).totalSupply()).to.equal(
			Number(totalSupply) + mintAmount
		);
	});

	it("should failed to mint if not owner", async () => {
		const mintAmount = 1000;

		await expect(
			ERC20.connect(userA).mint(userA.address, mintAmount)
		).to.be.revertedWithCustomError(ERC20, "OwnableUnauthorizedAccount");
	});

	it("should failed to mint if not owner", async () => {
		const mintAmount = 1000;

		await expect(
			ERC20.connect(userA).mint(userA.address, mintAmount)
		).to.be.revertedWithCustomError(ERC20, "OwnableUnauthorizedAccount");
	});

	it("should reject to mint more than Max Uint256", async () => {
		const mintAmount = ethers.constants.MaxUint256.add(1);

		await expect(ERC20.connect(owner).mint(userA.address, mintAmount)).to.be
			.rejected;
	});

	/// Apparently minting max uint256 with unchecked will lower the supply and balance by 1
	/// Why is that?
	// it("should reject to mint more than Max Uint256", async () => {
	// 	const mintAmount = ethers.constants.MaxUint256;

	// 	var balanceOf = await ERC20.balanceOf(userA.address);
	// 	var totalSupply = await ERC20.connect(owner).totalSupply();
	// 	console.log(balanceOf.toString());
	// 	console.log(totalSupply.toString());
	// 	const tx = await ERC20.connect(owner).mint(userA.address, mintAmount);
	// 	// const receipt = await tx.wait();
	// 	// const events = receipt.events[0].args;
	// 	// console.log(events);

	// 	var balanceOf = await ERC20.balanceOf(userA.address);
	// 	var totalSupply = await ERC20.connect(owner).totalSupply();
	// 	console.log(balanceOf.toString());
	// 	console.log(totalSupply.toString());
	// 	await ERC20.connect(owner).mint(userA.address, mintAmount);

	// 	var balanceOf = await ERC20.balanceOf(userA.address);
	// 	var totalSupply = await ERC20.connect(owner).totalSupply();
	// 	console.log(balanceOf.toString());
	// 	console.log(totalSupply.toString());
	// 	await ERC20.connect(owner).mint(userA.address, mintAmount);

	// 	var balanceOf = await ERC20.balanceOf(userA.address);
	// 	var totalSupply = await ERC20.connect(owner).totalSupply();
	// 	console.log(balanceOf.toString());
	// 	console.log(totalSupply.toString());
	// 	await ERC20.connect(owner).mint(userA.address, mintAmount);
	// });

	it("should be able to burn owned tokens", async () => {
		const balanceOf = await ERC20.balanceOf(owner.address);

		await ERC20.connect(owner).burn(balanceOf);

		const balanceAfter = await ERC20.balanceOf(owner.address);
		expect(balanceAfter).to.equal(0);
		expect(balanceAfter).to.not.be.equal(balanceOf);
	});

	it("should be able to burn 0 tokens and not affect anything", async () => {
		const balanceOf = await ERC20.balanceOf(owner.address);
		const totalSupply = await ERC20.connect(owner).totalSupply();

		await ERC20.connect(owner).burn(0);

		const balanceAfter = await ERC20.balanceOf(owner.address);
		expect(balanceAfter).to.be.equal(balanceOf);

		expect(await ERC20.connect(owner).totalSupply()).to.equal(
			Number(totalSupply)
		);
	});

	it("should not be able to burn unexistant tokens", async () => {
		const mintAmount = 1000;
		await ERC20.connect(owner).mint(owner.address, mintAmount);

		const balanceOf = await ERC20.balanceOf(owner.address);
		expect(balanceOf).to.be.lessThan(mintAmount * 2);

		await expect(
			ERC20.connect(owner).burn(mintAmount * 2)
		).to.be.revertedWithCustomError(ERC20, "ERC20InsufficientBalance");
	});
});
