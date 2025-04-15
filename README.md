# 🗳️ Governance Smart Contract

This smart contract enables a basic decentralized governance system where users can create, vote on, and execute proposals.

## 📌 What is it for?

It allows a community with assigned voting power to:

- Create proposals (requires at least 1000 voting power)
- Vote for or against proposals
- Execute proposals after the voting period ends

## ⚙️ How does it work?

1. **Voting Power**: Comes from staked tokens balance.
2. **Proposal Creation**: Users with at least 1000 voting power can create proposals.
3. **Voting**: Eligible voters can vote once per proposal (yes or no).
4. **Execution**: After the deadline, anyone can execute the proposal. If `yesVotes > noVotes`, it gets approved.

## ✨ Key Features

- `votingPower`: Tracks voting power from ``staked Giga Wei`` balance
- `VOTING_PERIOD`: Duration of voting (3 days)
- `approved`: Indicates whether a proposal passed or not

---
