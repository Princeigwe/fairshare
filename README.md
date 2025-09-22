# FairShare – Expense Splitter (Web3)

A Solidity smart contract that helps groups of friends fairly split expenses **on-chain**.  
No more awkward calculations, IOUs, or trust issues - everything is transparent and verifiable on Ethereum.
Sepolia Explorer: https://sepolia.basescan.org/address/0x7027379c68ce3f4CD3E6779B042a355F222AD5Ba
---

## Features
- Create groups and add members.  
- Record expenses paid by any member.  
- Automatically updates everyone’s balances (who owes and who is owed).  
- Members can settle up directly on-chain by paying back what they owe.  
- Balances are always transparent and auditable on the blockchain.  

---

## Example

### Scenario
- **Bob** pays `90 ETH` for a hotel in a 3-person group (Alice, Bob, Carol).  
  - Each owes `30 ETH`.  
  - Balances → Alice: `–30`, Carol: `–30`, Bob: `+60`.  

- **Alice** pays `60 ETH` for dinner.  
  - Each owes `20 ETH`.  
  - Balances → Alice: `+10`, Bob: `+40`, Carol: `–50`.  

- **Carol** settles up with Bob by calling `settleUp()` and sending ETH.  
  - Funds are transferred directly.  
  - Balances reset fairly.  

---

## Why FairShare?
FairShare demonstrates how Web3 can bring **transparency, fairness, and automation** to everyday activities like splitting bills.  
By recording group expenses on-chain, everyone can see exactly who owes what, and settlement happens **without intermediaries**.  

---

## Tech Stack
- **Solidity**  
- **Hardhat** 
- **Ethereum**  
- **Ethers.js**  

---

## 🔧 Getting Started

### 1. Clone the repo
```bash
git clone https://github.com/Princeigwe/fairshare.git
cd fairshare

```
### 2. Compile the contract
```bash
npx hardhat compile

```
### 3. Deploy
```bash
npx hardhat run deploy.ts --network localhost

```
