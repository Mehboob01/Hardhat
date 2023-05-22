require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-etherscan");

task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

const metamask_private_key = "8653f759523a1c0539685b20f2f2b29edb1d3ee07988bb4c2b05408cf1326624";
const etherscanAPIKey = "D82KIQMEPFRKUBZVXAY7A99UDNJ847A8H6";

module.exports = {
  solidity: "0.8.19",
  networks: {
    bscTestnet: {
      url: "https://data-seed-prebsc-2-s3.binance.org:8545",
      accounts: [metamask_private_key],
    },
    mainnet: {
      url: "https://mainnet.infura.io/v3/PROJECT_ID",
      accounts: [metamask_private_key],
    },
  },
  etherscan: {
    apiKey: etherscanAPIKey,
  },
};
