const { ethers, hre } = require("hardhat");

async function main() {
  const [deployer] = await ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer.address);

  console.log("Account balance:", (await deployer.getBalance()).toString());

  const token="0xfCacB1e616F0Aa55378a68fb3A815444CFF9f9fc";
  const defaultReferrer="0xb5fc14ee4DBA399F9043458860734Ed33FdCd96E";

  const BigDaddy = await ethers.getContractFactory("BigDaddy");
  const bigDaddy = await BigDaddy.deploy(token,defaultReferrer);
  await bigDaddy.deployed();

  console.log("Contract address:", bigDaddy.address);

  if (hre.network.name !== "hardhat") {
    console.log("Verifying contract on Etherscan...");
    try {
      await hre.run("verify:verify", {
        address: bigDaddy.address,
        constructorArguments: [token, defaultReferrer], // Pass the actual values here
      });
      console.log("Contract verified on Etherscan!");
    } catch (error) {
      console.error("Failed to verify contract on Etherscan:", error);
    }
  }
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
