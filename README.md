# HashRewards

HashRewards is a privacy-first quest engine built on Monad.

Users complete quests and earn points. Each action generates an encrypted receipt whose hash is stored on-chain.

## Architecture

HashRewards uses a hybrid model:

- Off-chain encrypted receipts
- On-chain hash anchoring
- On-chain points accounting

Only receipt hashes are stored on-chain to preserve user privacy.

## Smart Contract

Network: Monad Testnet  
Address: 0x71065d406B5Ee090A98AE00ef197a23Bf9cD1b64

## Stack

- Solidity 0.8.28
- Hardhat v2
- Ethers v6
- TypeScript
