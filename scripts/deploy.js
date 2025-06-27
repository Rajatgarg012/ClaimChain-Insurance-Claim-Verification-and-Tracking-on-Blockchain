const hre = require("hardhat");

async function main() {
  const ClaimChain = await hre.ethers.getContractFactory("ClaimChain");
  const claims = await ClaimChain.deploy();
  await claims.deployed();

  console.log("ClaimChain deployed to:", claims.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
