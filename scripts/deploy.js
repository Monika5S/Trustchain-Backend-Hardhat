const hre = require("hardhat"); // Import hardhat runtime environment

async function main() {
  const ContractFactory = await hre.ethers.getContractFactory("Trustchain"); // Replace with your contract name
  const contract = await ContractFactory.deploy();

  await contract.deployed();
  console.log("Contract deployed to address:", contract.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
