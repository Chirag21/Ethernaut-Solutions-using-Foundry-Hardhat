# <h1 align="center"> Ethernaut Solutions [Foundry - Hardhat]</h1>

### _Never place private keys or secret phrase or mnemonic in a .env file that is associated with real funds. Only place private keys in a .env file that have ONLY testnet ETH, LINK, or other cryptocurrencies._

---

*__The Ethernaut is a Web3/Solidity based wargame inspired by [overthewire](https://overthewire.org), played in the Ethereum Virtual Machine. The game acts both as a tool for those interested in learning ethereum, and as a way to catalogue historical hacks as levels. Level contracts are taken from [Ethernaut's repo.](https://github.com/OpenZeppelin/ethernaut)__*

### Getting Started
The repo includes Ethernaut solutions built with Hardhat and Foundry. The `src/` folder contains the Ethernaut level contracts. The tests for the exploits are present in the `test/` folder. `script` and `scripts` folder contain the scripts that can be run on the testnet. These scripts carry out the exploitation.
Note that the `script/` folder contains scripts for Foundry, written in Solidity, while the `scripts/` folder contains scripts for Hardhat, written in Typescript.
### Install
- [Install Node.js](https://nodejs.org/en/)

- [Install pnpm](https://pnpm.io/installation)

- [Install Foundry](https://book.getfoundry.sh/getting-started/installation)

- [Install Hardhat](https://hardhat.org/hardhat-runner/docs/getting-started#installation)

- Clone the repo
```bash
git clone https://github.com/Chirag21/Ethernaut-solutions.git
```
- Inside project directory run following commands

```bash
pnpm install
```

```bash
forge install
```
---

### Run tests
- Using Foundry:-
     - ```
       forge test -vvvv --match-test [testFunctionName]
        ```
    
    eg. ```forge test -vvvv --match-test testFalloutContract```
    
- Using Hardhat
    - ```
      pnpm run test [testFilePath]
      ```

    eg. ```pnpm run test test/hardhat/2_fallout.test.ts```

    Add `--no-compile` for fast compilation.
    
---

### Spin up local node
Get private RPC url from [Alchemy](https://www.alchemy.com/overviews/private-rpc-endpoint). When compared to the public RPC url, this will allow transactions to be broadcasted more quickly. 

For local node, I prefer using [Anvil](https://book.getfoundry.sh/anvil/). Anvil is a local testnet node shipped with Foundry.
To start the node
```
anvil --chain-id 169
```
To fork the testnet
```
anvil --chain-id 169 --fork-url [yourRPCUrl] --fork-block-number [blockNumberToForkFrom]
```
Copy the Anvil private key and paste it into the `.env` file against `"ANVIL_PRIVATE_KEY."`

---

### Run exploit scripts
Before running the exploit on testnet, first simulate it on the local forked node.
Fork the testnet on local.
Run script on local node

- Using Foundry 
    - ```
      forge script [pathOfTheScript] -vvvv --rpc-url localhost
      ```
    
    eg. ```
      forge script script/1_FallbackScript.sol -vvvv --rpc-url localhost
      ```

- Using Hardhat
    - ```
      pnpm run [pathOfTheScript] --no-compile --network anvil
      ```
    
    eg. ```
      pnpm run scripts/2_fallout_exploit.ts --no-compile --network anvil
      ```

Execute the exploit on testnet (__Remember to use `"PRIVATE_KEY"` from `.env`__.)

- Using Foundry
    - ```
      forge script [pathOfTheScript] -vvvv --rpc-url [rpcUrl]
      ```
    - Add rpc-url from `foundry.toml`
    
    eg. ```
      forge script [pathOfTheScript] -vvvv --rpc-url mumbai
      ```

- Using Hardhat
    - ```
      pnpm run scripts/2_fallout_exploit.ts --no-compile --network [networkName]
      ```
      
    - Add network from `hardhat.config.ts`
    
    eg. ```
      pnpm run scripts/2_fallout_exploit.ts --no-compile --network mumbai
      ```
---

### How to use the repo:-
- Get the new instance of the level on the Ethernaut site. Copy the instance address and put it in the [`.env`](https://github.com/Chirag21/Ethernaut-solutions/blob/main/.evn-example) file. You can get the instance address by typing `instance` the dev console on Ehternaut site. Also, copy the block number of the transaction. We will need the block number for forking the testnet on the local test node.

- Write the test for the exploit. For reference, look in the `test` folder. You can directly write the script by skipping the test.

- Write the script that will run on the testnet. For reference, look in the `script` folder for Foundry or `scripts` folder for Hardhat. 
- For testing the script, fork testnet on local. You can use the [Hardhat node](https://hardhat.org/hardhat-network/docs/overview) or [Anvil](https://book.getfoundry.sh/anvil/). Simulate the transaction on local node. __Remember to use `"ANVIL_PRIVATE_KEY"` from `.env`__.

- Once the simulation is successful, run the test on the testnet network. After successful execution, go to the level page on the Ethernaut and submit the instance. __Remember to use `"PRIVATE_KEY"` from `.env`__.


### _Never place private keys or secret phrase or mnemonic in a .env file that is associated with real funds. Only place private keys in a .env file that have ONLY testnet ETH, LINK, or other cryptocurrencies._
