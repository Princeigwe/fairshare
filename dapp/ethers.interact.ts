import { ethers } from "ethers";
import { abi } from "./fairshare.abi";

const dotenv = require("dotenv")
dotenv.config()

const providerUrl = process.env.PROVIDER_URL || "http://localhost:8545";
const provider = new ethers.JsonRpcProvider(providerUrl);

const fairShareAddress = `0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512`;

const hardhatPrivateKey = `0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80`

const eoAddressPrivateKey = process.env.EO_ADDRESS_PRIVATE_KEY || hardhatPrivateKey;
const wallet = new ethers.Wallet(eoAddressPrivateKey, provider);

const fairShareContractConnect = new ethers.Contract(fairShareAddress, abi, wallet);


async function createGroup(name: string, description: string) {
  try {
    const tx = await fairShareContractConnect.createGroup(name, description);
    console.log("Group created successfully:", tx);
  } catch (error) {
    console.error("Error creating group:", error);
  }
}


async function getGroups() {
  try {
    const groups = await fairShareContractConnect.getGroups();
    console.log("Groups:", groups);
  } catch (error) {
    console.error("Error fetching groups:", error);
  }
}


async function getGroup(groupTag: string) {
  try {
    const group = await fairShareContractConnect.getGroup(groupTag);
    console.log("Group:", group);
  } catch (error) {
    console.error("Error fetching group:", error);
  }
}


async function addMember(groupTag: string, addr: string, displayName: string) {
  try {
    const tx = await fairShareContractConnect.addMember(groupTag, addr, displayName);
    console.log("Member added successfully:", tx);
  } catch (error) {
    console.error("Error adding member:", error);
  }
}

async function getGroupMembers(groupTag: string) {
  try {
    const members = await fairShareContractConnect.getGroupMembers(groupTag);
    console.log("Group Members:", members);
  } catch (error) {
    console.error("Error fetching group members:", error);
  }
}

async function payExpense(groupTag: string, expenseName: string, amountEther: string, payeeAddress: string) {
  try {
    const txOption = {value: ethers.parseEther(amountEther.toString())}
    const tx = await fairShareContractConnect.payExpense(groupTag, expenseName, payeeAddress, txOption)
    console.log("Expense paid successfully:", tx);
  } catch (error) {
    console.error("Error paying expense:", error);
  }
}


// createGroup("Group Name", "Group Description")
// getGroups()
// getGroup("Group Name-0")
// addMember("Group Name-0", "0x70997970C51812dc3A010C7d01b50e0d17dc79C8", "mattedy")
// addMember("Group Name-0", "0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC", "slyX")
// getGroupMembers("Group Name-0")


const dummyPayeeAddress = `0x8626f6940E2eb28930eFb4CeF49B2d1F2C9C1199`
payExpense("Group Name-0", "Dinner", "0.01", dummyPayeeAddress)