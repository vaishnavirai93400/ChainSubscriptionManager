const { ethers } = require("hardhat");

async function main() {
  console.log("Deploying ChainSubscriptionManager to Core Blockchain...");

  // Get the contract factory
  const ChainSubscriptionManager = await ethers.getContractFactory("ChainSubscriptionManager");

  // Deploy the contract
  const chainSubscriptionManager = await ChainSubscriptionManager.deploy();

  // Wait for the deployment to be confirmed
  await chainSubscriptionManager.deployed();

  console.log("ChainSubscriptionManager deployed successfully!");
  console.log("Contract Address:", chainSubscriptionManager.address);
  console.log("Transaction Hash:", chainSubscriptionManager.deployTransaction.hash);
  console.log("Deployed on Core Testnet (Chain ID: 1114)");
  
  // Verify deployment
  const owner = await chainSubscriptionManager.owner();
  console.log("Contract Owner:", owner);
  
  // Get deployer address
  const [deployer] = await ethers.getSigners();
  console.log("Deployer Address:", deployer.address);
  console.log("Deployer Balance:", ethers.utils.formatEther(await deployer.getBalance()), "CORE");

  console.log("\n=== Deployment Summary ===");
  console.log("Network: Core Testnet");
  console.log("RPC URL: https://rpc.test2.btcs.network");
  console.log("Chain ID: 1114");
  console.log("Contract: ChainSubscriptionManager");
  console.log("Address:", chainSubscriptionManager.address);
  console.log("===============================");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("Deployment failed:", error);
    process.exit(1);
  });