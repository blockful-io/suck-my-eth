import { ethers } from "hardhat";

async function main() {
  const [signer] = await ethers.getSigners();
  const BlackholeFactory = await ethers.deployContract("BlackholeFactory");
  const blackholeFactory = await BlackholeFactory.waitForDeployment();
  const address = await blackholeFactory.getAddress();

  console.log("\b blackholeFactory deployed to:", address);

  await blackholeFactory.suckTheEther({ value: ethers.WeiPerEther });
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
  });
