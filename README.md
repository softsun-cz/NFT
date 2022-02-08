# NFT - smart contracts

1. Edit .secret and put there a wallet mnemonic phrase (24 words) - you need to have some gas on it
2. Register on polygonscan.com, bscscan.com etc. and create your new API keys
3. Edit .apikey_* files and add your api keys on the first line of each file (* means block explorer name, e.g.: polygonscan, bscscan ...)
4. edit ./migrations/2_deploy_contracts.js and set variables
5. Install dependencies and run deploy script:
```console
yarn install
./deploy.sh
```

# Used dependencies

- Hardhat 2.8.3
- Solidity 0.8.11
- Node v16.13.1
- NPM 8.3.0
- Web3.js v1.5.3
- Yarn 1.22.17
