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
		const Factory = await ethers.getContractFactory("BlackholeToken", owner);
		const Contract = await Factory.deploy("Blackhole", "BLACK", owner.address);
		ERC20 = await Contract.deployed();

		expect(await ERC20.name()).to.equal("Blackhole");
		expect(await ERC20.symbol()).to.equal("BLACK");
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
		await expect(
			ERC20.decreaseAllowance(userA.address, 1000)
		).to.be.revertedWithCustomError(ERC20, "ERC20FailedDecreaseAllowance");
	});

	it("Should be able to permit userA to move tokens of owner", async () => {
		const _owner = owner.address;
		const spender = userA.address;
		const value = 1000;
		const nonce = await ERC20.nonces(owner.address);
		const deadline = ethers.constants.MaxUint256;

		const domain = {
			name: "Blackhole",
			version: "1",
			chainId: (await ethers.provider.getNetwork()).chainId,
			verifyingContract: ERC20.address,
		};

		const types = {
			Permit: [
				{ name: "owner", type: "address" },
				{ name: "spender", type: "address" },
				{ name: "value", type: "uint256" },
				{ name: "nonce", type: "uint256" },
				{ name: "deadline", type: "uint256" },
			],
		};

		const permit = {
			owner: _owner,
			spender: spender,
			value: value,
			nonce: nonce,
			deadline: deadline,
		};

		const signature = await owner._signTypedData(domain, types, permit);
		const sig = ethers.utils.splitSignature(signature);

		await ERC20.permit(_owner, spender, value, deadline, sig.v, sig.r, sig.s);

		expect(await ERC20.allowance(_owner, spender)).to.equal(value.toString());
	});

	it("Should not be able to use a permit a second time", async () => {
		const _owner = owner.address;
		const spender = userA.address;
		const value = 1000;
		const nonce = await ERC20.nonces(_owner);
		const deadline = ethers.constants.MaxUint256;

		const domain = {
			name: "Blackhole",
			version: "1",
			chainId: (await ethers.provider.getNetwork()).chainId,
			verifyingContract: ERC20.address,
		};

		const types = {
			Permit: [
				{ name: "owner", type: "address" },
				{ name: "spender", type: "address" },
				{ name: "value", type: "uint256" },
				{ name: "nonce", type: "uint256" },
				{ name: "deadline", type: "uint256" },
			],
		};

		const permit = {
			owner: _owner,
			spender: spender,
			value: value,
			nonce: nonce.sub(1),
			deadline: deadline,
		};

		const signature = await owner._signTypedData(domain, types, permit);
		const sig = ethers.utils.splitSignature(signature);

		await expect(
			ERC20.permit(_owner, spender, value, deadline, sig.v, sig.r, sig.s)
		).to.be.revertedWithCustomError(ERC20, "ERC2612InvalidSigner");
	});

	it("Should not be able to use an expired permit", async () => {});
	it("Should not be able to use a permit with wrong signer", async () => {});
	it("Should consume allowance when used", async () => {});
	it("Should not consume allowance when set as max uint256", async () => {});
});
