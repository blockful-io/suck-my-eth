import { ethers } from "hardhat";
import { expect } from "chai";
import { Contract } from "ethers";

describe("TestERC20", function () {
	let ERC20: Contract;
	let signer: any;
	let userA: any;
	let userB: any;

	before(async () => {
		[signer, userA, userB] = await ethers.getSigners();
		const Factory = await ethers.getContractFactory("MatterToken", signer);
		const Contract = await Factory.deploy(
			"MatterToken",
			"MATTER",
			signer.address
		);
		ERC20 = await Contract.deployed();

		expect(await ERC20.name()).to.equal("TestERC20");
		expect(await ERC20.symbol()).to.equal("MATTER");
		expect(await ERC20.decimals()).to.equal(18);
	});
});
