import hre from "hardhat";

async function main() {
  const [deployer] = await hre.ethers.getSigners();
  console.log("Deploying contracts with the account:", deployer.address);

  const FairShare = await hre.ethers.getContractFactory("FairShare");
  const fairShare = await FairShare.deploy({ from: deployer.address });
  console.log("FairShare deployed to:", await fairShare.getAddress());
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });