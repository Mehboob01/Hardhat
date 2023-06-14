const { ethers, run } = require("hardhat");

async function main() {
  try {
    const [deployer] = await ethers.getSigners();
    const network = await ethers.provider.getNetwork();

    console.log("Deploying contracts with the account:", deployer.address);

    const balance = await deployer.getBalance();
    const balanceInEther = ethers.utils.formatEther(balance);
    console.log("Account balance:", balanceInEther);

    const block = await ethers.provider.getBlock(await ethers.provider.getBlockNumber());
    const timestamp = block.timestamp;
    const date = new Date(timestamp * 1000);

    const formattedDate = date.toLocaleString("en-US", {
      weekday: "long",
      year: "numeric",
      month: "long",
      day: "numeric",
      hour: "numeric",
      minute: "numeric",
      second: "numeric",
      timeZoneName: "short",
    });

    console.log("Real-time Timestamp:", formattedDate);

    const blockchainInfo = {
      name: network.name,
      chainId: network.chainId,
      blockNumber: block.number,
      timestamp: timestamp,
    };

    console.log("Blockchain Info:");
    console.table(blockchainInfo);

    const Owership = await ethers.getContractFactory("Owership");
    const token = await Owership.deploy('0xb5fc14ee4DBA399F9043458860734Ed33FdCd96E');
    await token.deployed();

    console.log("Contract address:", token.address);

    if (network.name !== "hardhat") {
      console.log("Verifying contract on the network...");
      await verifyContract(token.address);
      console.log("Contract verified on the network!");
    }
  } catch (error) {
    console.error("An error occurred:", error);
  }
}

async function verifyContract(contractAddress) {
  try {
    await run("verify:verify", {
      address: contractAddress,
      constructorArguments: ['0xb5fc14ee4DBA399F9043458860734Ed33FdCd96E'], // Pass the actual values here
    });
  } catch (error) {
    console.error("Failed to verify contract on the network:", error);
    throw error;
  }
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
