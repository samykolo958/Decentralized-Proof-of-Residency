# 🏠 Decentralized Proof-of-Residency

> Community-powered verification of where people actually live 🌍

## 📋 Overview

A blockchain-based system where community members vote to verify residency claims, creating a decentralized and trustworthy proof-of-residency solution.

## ✨ Features

- 🗳️ **Community Voting**: Neighbors verify where residents actually live
- ⏰ **Time-based Voting**: Configurable voting periods for fair participation  
- 🏆 **Reputation System**: Track voter participation and build trust
- 🔒 **Tamper-proof**: Immutable verification records on blockchain
- ⚖️ **Consensus Mechanism**: 60% approval rate required for verification

## 🚀 Quick Start

### Submit Residency Claim
```clarity
(contract-call? .Decentralized-Proof-of-Residency submit-claim "123 Main Street, City")
```

### Vote on Claims
```clarity
;; Vote YES (true) or NO (false)
(contract-call? .Decentralized-Proof-of-Residency vote-on-claim u1 true)
```

### Finalize Verified Claims
```clarity
(contract-call? .Decentralized-Proof-of-Residency finalize-claim u1)
```

## 📊 Core Functions

### 🏡 For Residents
- `submit-claim` - Submit your residency claim with location
- `get-verified-resident` - Check if someone is verified

### 🗳️ For Community Voters  
- `vote-on-claim` - Vote YES/NO on residency claims
- `get-voter-reputation` - Check your voting reputation
- `has-voted` - Check if you already voted on a claim

### 📈 For Everyone
- `get-claim` - View claim details and voting status
- `is-voting-active` - Check if voting is still open
- `get-settings` - View contract configuration

## ⚙️ Configuration

**Default Settings:**
- Minimum votes required: **3**
- Voting period: **144 blocks** (~24 hours)
- Approval threshold: **60%**

## 🔄 Process Flow

1. **🏠 Submit Claim** → Resident submits location
2. **🗳️ Community Votes** → Neighbors vote during voting period
3. **✅ Auto-Finalize** → Claims auto-resolve after voting ends
4. **🎉 Get Verified** → Successful claims become permanent records

## 📝 Example Usage

```clarity
;; 1. Submit your residency claim
(contract-call? .Decentralized-Proof-of-Residency submit-claim "456 Oak Avenue, Springfield")

;; 2. Community members vote (claim ID 1)
(contract-call? .Decentralized-Proof-of-Residency vote-on-claim u1 true)

;; 3. After voting period ends, finalize
(contract-call? .Decentralized-Proof-of-Residency finalize-claim u1)

;; 4. Check verification status
(contract-call? .Decentralized-Proof-of-Residency get-verified-resident 'SP1HTBVD3JG9C05J7HBJTHGR0GGW7KXW28M5JS8QE)
```

## 🛡️ Security Features

- **Anti-self-voting**: Residents cannot vote on their own claims
- **One-vote-per-claim**: Prevents vote manipulation
- **Time-locked voting**: Clear voting windows prevent late manipulation
- **Reputation tracking**: Builds long-term community trust

## 🏗️ Development

### Testing
```bash
clarinet test
```

### Deploy
```bash
clarinet deploy
```

## 📋 Contract Status Codes

- `pending` - Claim submitted, voting active
- `approved` - Community verified residency (≥60% yes votes)
- `rejected` - Community rejected claim (<60% yes votes)

---

**Built with ❤️ for decentralized communities**
