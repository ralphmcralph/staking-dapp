# 💎 StakingApp – Fixed-Amount Token Staking Smart Contract

![Solidity](https://img.shields.io/badge/Solidity-0.8.24-blue?style=flat&logo=solidity)
![License](https://img.shields.io/badge/License-LGPL--3.0--only-green?style=flat)
![Tested](https://img.shields.io/badge/Tested%20With-Foundry-orange?style=flat)
![Coverage](https://img.shields.io/badge/Coverage-100%25-brightgreen?style=flat)

---

## 📌 Description

**StakingApp** is a simple and efficient staking smart contract system that allows users to deposit a fixed amount of ERC20 tokens and receive ETH rewards after a staking period. Built in Solidity with full test coverage using **Foundry**, it demonstrates:

- Token-based staking mechanism
- Fixed deposit and reward amounts
- Robust access control with `Ownable`
- ETH funding for rewards
- Time-based staking logic

This project is designed as a showcase to impress recruiters, demonstrating smart contract skills, test-driven development, and best practices.

---

## 🧱 Components

### 🔹 StakingApp.sol

Main staking contract logic.

### 🔹 StakingToken.sol

ERC20-compliant token used for staking.

### 🔹 Tests

Includes full coverage of deployment, permissions, staking, reward claiming, and reverts using **Foundry**.

---

## 📁 Structure

```
├── src/
│   ├── StakingApp.sol
│   └── StakingToken.sol
├── test/
│   ├── StakingApp.t.sol
│   └── StakingToken.t.sol
```

---

## 🚀 Features

### ✅ depositTokens

Allows users to stake exactly 10 tokens.

```solidity
function depositTokens(uint256 tokenAmount_) external
```

### 🔁 withdrawTokens

Users can withdraw their staked tokens.

```solidity
function withdrawTokens() external
```

### 🎁 claimRewards

After `stakingPeriod`, users can claim ETH rewards.

```solidity
function claimRewards() external
```

### ⚙️ changeStakingPeriod

Admin can update staking duration.

```solidity
function changeStakingPeriod(uint256 newPeriod) external onlyOwner
```

### 💵 receive()

Only owner can fund contract with ETH.

```solidity
receive() external payable onlyOwner
```

---

## 🧪 Testing

Tested with **Foundry** covering:

- Owner-only access control
- ETH funding mechanics
- Token deposits, withdrawals
- Time-warping and reward eligibility
- All error conditions and revert paths

100% coverage achieved (lines, functions, branches).

---

## 📄 License

Licensed under **LGPL-3.0-only**.

---

## 🙋‍♂️ Author & Contributions

Built as a demonstration project to strengthen smart contract development skills and showcase capabilities to potential employers.

Open to ideas, suggestions, and PRs 🚀
