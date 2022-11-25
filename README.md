# <h1 align="center"> Ethernaut Solutions </h1>

**The Ethernaut is a Web3/Solidity based wargame inspired by [overthewire](https://overthewire.org), played in the Ethereum Virtual Machine. The game acts both as a tool for those interested in learning ethereum, and as a way to catalogue historical hacks as levels. Level contracts are taken from [Ethernaut's repo.](https://github.com/OpenZeppelin/ethernaut)**

### Getting Started

- Use Foundry:

```bash
forge install
forge test
```

- Use Hardhat:

```bash
npm install
npx hardhat test
```

### Features

- Write / run tests with either Hardhat or Foundry:

```bash
forge test
# or
npx hardhat test
```

- Use Hardhat's task framework

```bash
npx hardhat example
```

- Install libraries with Foundry which work with Hardhat.

```bash
forge install rari-capital/solmate # Example
```

### Notes

Whenever you install new libraries using Foundry, make sure to update your `remappings.txt` file by running `forge remappings > remappings.txt`. This is required because we use `hardhat-preprocessor` and the `remappings.txt` file to allow Hardhat to resolve libraries you install with Foundry.
