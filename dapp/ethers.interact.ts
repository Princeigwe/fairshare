import { ethers } from "ethers";
import { abi } from "./fairshare.abi";

const dotenv = require("dotenv")
dotenv.config()

const providerUrl = process.env.PROVIDER_URL || "http://localhost:8545";
const provider = new ethers.JsonRpcProvider(providerUrl);

const fairShareAddress = `0x5FbDB2315678afecb367f032d93F642f64180aa3`;

const hardhatPrivateKey = `0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d`

const eoAddressPrivateKey = process.env.EO_ADDRESS_PRIVATE_KEY || hardhatPrivateKey;
const wallet = new ethers.Wallet(eoAddressPrivateKey, provider);

const fairShareContractConnect = new ethers.Contract(fairShareAddress, abi, wallet);


async function getGroups() {
  try {
    const groups = await fairShareContractConnect.getGroups();
    console.log("Groups:", groups);
  } catch (error) {
    console.error("Error fetching groups:", error);
  }
}


getGroups()