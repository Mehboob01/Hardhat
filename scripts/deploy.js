const { ethers } = require("hardhat");

async function main() {
  const [deployer] = await ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer.address);

  console.log("Account balance:", (await deployer.getBalance()).toString());
 
  // pass value as a constructor
  const token = "100000";
  
  const SimpleToken = await ethers.getContractFactory("SimpleToken");
  const simpleToken = await SimpleToken.deploy(token);
  await simpleToken.deployed();

  console.log("Contract address:", simpleToken.address);

  if (network.name !== "hardhat") {
    console.log("Verifying contract on BSC Testnet Network...");
    try {
      await run("verify:verify", {
        address: simpleToken.address,
        constructorArguments: [token], // Pass the actual values here
      });
      console.log("Contract verified on BSC Testnet Network!");
    } catch (error) {
      console.error("Failed to verify contract on BSC Testnet Network:", error);
    }
  }
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
