# Referral System Smart Contract 

## ✨ Overview
This project is a **Referral System** smart contract written in Solidity, designed for the **Foundry** framework. The contract allows users to participate in a structured referral program, rewarding participants for referring new users and ensuring fair distribution of rewards up the hierarchy.

## 🌟 Features
- ✅ **User Participation**: Users can join the referral system by providing a referral ID and staking tokens.
- 🎁 **Referral Rewards**: Automated reward distribution to referrers based on hierarchical rules.
- 🌲 **Tree Structure**: Users are assigned as left or right children under their referrer.
- 🔥 **Multi-Level Reward System**: The contract supports different levels of rewards based on user participation and referrals.
- 🛡️ **Security & Validations**: Includes multiple error handling mechanisms to ensure fair and secure participation.
- 💰 **Owner Profit Collection**: The contract automatically transfers the remaining balance to the owner after user rewards are distributed.

## 🛠️ Technologies Used
- 📝 **Solidity (v0.8.2)**
- 🚀 **Foundry Framework**
- 💳 **ERC-20 Interface** for token transfers

## 📜 Contract Breakdown
### 🏛️ Smart Contract: `refferalContract.sol`
The contract includes:
- **📌 State Variables:**
  - `IERC20 MYUSDT` → The ERC-20 token used for participation and rewards.
  - `address owner` → The contract deployer and fund collector.
  - `mapping(address => User) addressToUserStruct` → Stores user details.
- **📦 Structs:**
  - `User` → Stores user details including parent, children, and unlocked levels.
- **🔧 Functions:**
  - `participate(address referralId, uint256 amount)` → Allows users to join the referral system.
  - `createUserStruct(uint256 _amount, address _userAdd, address _parent)` → Internal function for user struct creation and tree structure maintenance.
  - `distributeReferralRewards(address parent, uint256 amount)` → Distributes rewards to referrers.

## 🏗️ Installation & Setup
### 📌 Prerequisites
- **Foundry** installed. If not, install it using:
  ```sh
  curl -L https://foundry.paradigm.xyz | bash
  foundryup
  ```
- **Node.js & npm** (optional, for additional tooling)

### 📥 Clone the Repository
```sh
git clone https://github.com/Elmirataghinasab/ReffralSystem.git
cd ReffralSystem
```

### 📦 Install Dependencies
```sh
forge install
```

### 🔨 Compile the Contract
```sh
forge build
```

### 🧪 Run Tests
```sh
forge test
```

## 🛠️ Testing
The project includes **unit tests** written using Foundry’s testing framework.
To run all tests:
```sh
forge test --gas-report
```

## 🤝 Contribution
1. 🍴 Fork the repository
2. 🌿 Create a new branch (`git checkout -b feature-branch`)
3. 📝 Commit changes (`git commit -m 'Add new feature'`)
4. 📤 Push to the branch (`git push origin feature-branch`)
5. 🛎️ Open a pull request

## 📜 License
This project is licensed under the **MIT License**.

## 📬 Contact
For any questions or suggestions, feel free to reach out via GitHub Issues or email: **etaghinasab83@gmail.com**.

---
**🚀 Happy Building! 🔥**

