import { ethers } from "ethers";
import { abi } from "./fairshare.abi";

const dotenv = require("dotenv")
dotenv.config()

const providerUrl = process.env.PROVIDER_URL || "http://localhost:8545";
const provider = new ethers.JsonRpcProvider(providerUrl);

const fairShareAddress = `0x5FbDB2315678afecb367f032d93F642f64180aa3`;

const hardhatPrivateKey = `0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80` // first wallet on the list

const eoAddressPrivateKey = process.env.EO_ADDRESS_PRIVATE_KEY || hardhatPrivateKey;
const wallet = new ethers.Wallet(eoAddressPrivateKey, provider);

const fairShareContractConnect = new ethers.Contract(fairShareAddress, abi, wallet);


// ** EXTRA DUMMY WALLET CONNECTIONS

// *  CLIENT 1 - Matt
const mattPrivateKey = `0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d` // 2nd wallet on list
const mattWallet = new ethers.Wallet(mattPrivateKey, provider)
const mattContractConnect = new ethers.Contract(fairShareAddress, abi, mattWallet)


// * CLIENT 2 - SlyX
const slyXPrivateKey = `0x5de4111afa1a4b94908f83103eb1f1706367c2e68ca870fc3fb9a804cdab365a` // 3rd wallet on the list
const slyXWallet = new ethers.Wallet(slyXPrivateKey, provider)
const slyXContractConnect = new ethers.Contract(fairShareAddress, abi, slyXWallet)





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

async function getGroupBalances(groupTag: string) {
  try {
    const balances = await fairShareContractConnect.getGroupBalances(groupTag);
    console.log("Group Balances:", balances);
  } catch (error) {
    console.error("Error fetching group balances:", error)
  }
}

async function payExpense(groupTag: string, expenseName: string, amountEther: number, payeeAddress: string) {
  try {
    const txOption = {value: ethers.parseEther(amountEther.toString())}
    const tx = await fairShareContractConnect.payExpense(groupTag, expenseName, payeeAddress, txOption) // calling contract function with eth value
    fairShareContractConnect.on("PaidExpenseResponse", (message, groupTag, expense, memberCount) => { 
      console.log("Expense Paid Event:", {message, groupTag, expense, memberCount});
      fairShareContractConnect.removeAllListeners("PaidExpenseResponse"); // remove listener after event is captured
    })
  } catch (error) {
    console.error("Error paying expense:", error);
  }
}


async function getWalletBalance(payeeAddress: string) {
  try {
    const balance = await provider.getBalance(payeeAddress);
    console.log(`Payee Wallet Balance (${payeeAddress}):`, ethers.formatEther(balance));
  } catch (error) {
    console.error("Error fetching payee wallet balance:", error);
  }
}

async function getGroupExpenses(groupTag: string) {
  try {
    const expenses = await fairShareContractConnect.getExpenses(groupTag);
    console.log("Group Expenses:", expenses);
  } catch (error) {
    console.error("Error fetching group expenses:", error);
  }
}

//////////////////////////////////////////////////////////////////////
async function getUserBalance(groupTag: string) {
  try {
    const balance = await fairShareContractConnect.getUserBalance(groupTag)
    console.log("Balance:", `${ethers.formatEther(balance)} ETH`)
  } catch (error) {
    console.error("Error fetch balance for user: ", error);
  }
}


async function getMattBalance(groupTag: string) {
  try {
    const balance = await mattContractConnect.getUserBalance(groupTag)
    console.log("Balance:", `${ethers.formatEther(balance)} ETH`)
  } catch (error) {
    console.error("Error fetch balance for user: ", error);
  }
}


async function getSlyXBalance(groupTag: string) {
  try {
    const balance = await slyXContractConnect.getUserBalance(groupTag)
    console.log("Balance:", `${ethers.formatEther(balance)} ETH`)
  } catch (error) {
    console.error("Error fetch balance for user: ", error);
  }
}
///////////////////////////////////////////////////////////////////////////////////

async function settleUp(groupTag: string, amountEther: number) {
  try {
    const txOption = {value: ethers.parseEther(amountEther.toString())}
    await fairShareContractConnect.settleUp(groupTag, txOption)
    fairShareContractConnect.on('Settlement', (message, balance, addr, displayName) => {
      console.log('Settlement Event', {message, balance, addr, displayName})
      fairShareContractConnect.removeAllListeners("Settlement")
    })
  } catch (error) {
    console.error("Error settling debt in group: ", error);
  }
}

async function mattSettleUp(groupTag: string, amountEther: number) {
  try {
    const txOption = {value: ethers.parseEther(amountEther.toString())}
    await mattContractConnect.settleUp(groupTag, txOption)
    mattContractConnect.on('Settlement', (message, balance, addr, displayName) => {
      console.log('Settlement Event', {message, balance, addr, displayName})
      mattContractConnect.removeAllListeners("Settlement")
    })
  } catch (error) {
    console.error("Error settling debt in group: ", error);
  }
}


async function slyXSettleUp(groupTag: string, amountEther: number) {
  try {
    const txOption = {value: ethers.parseEther(amountEther.toString())}
    await slyXContractConnect.settleUp(groupTag, txOption)
    slyXContractConnect.on('Settlement', (message, balance, addr, displayName) => {
      console.log('Settlement Event', {message, balance, addr, displayName})
      slyXContractConnect.removeAllListeners("Settlement")
    })
  } catch (error) {
    console.error("Error settling debt in group: ", error);
  }
}

// createGroup("Group Name", "Group Description")
// getGroups()
// getGroup("Group Name-0")
addMember("Group Name-0", "0x70997970C51812dc3A010C7d01b50e0d17dc79C8", "mattedy")
// addMember("Group Name-0", "0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC", "slyX")
// getGroupMembers("Group Name-0")
// getGroupBalances("Group Name-0")



const dummyPayeeAddress = `0x8626f6940E2eb28930eFb4CeF49B2d1F2C9C1199`
// payExpense("Group Name-0", "Dinner", 3, dummyPayeeAddress)

// getWalletBalance(dummyPayeeAddress)
// getGroupExpenses("Group Name-0")

// getUserBalance("Group Name-0")
// getMattBalance("Group Name-0")
// getSlyXBalance("Group Name-0")


const debtAmount = 1
// settleUp("Group Name-0", debtAmount)
// mattSettleUp("Group Name-0", debtAmount)
// slyXSettleUp("Group Name-0", debtAmount)
