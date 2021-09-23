// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");
const {ethers} = require("ethers");


const ACCOUNT = "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266";

async function blockNumber() {
  return await hre.network.provider.send("eth_blockNumber", []);
}

async function showBlockNumber() {
  console.log(`block number: ${await blockNumber()}`)
}

function getApproxGasCost(txResult) {
  const gasUsed = txResult.gasUsed;
  const gasCost = ethers.BigNumber.from(64); // gwei
  const ethCostGwei = gasUsed.mul(gasCost);
  const ethCostEth = ethCostGwei / 1.0e18;
  const ethPrice = 3000.0;
  return ethCostEth * ethPrice;
}

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');

  // We get the contract to deploy
  const Pow = await hre.ethers.getContractFactory("Pow");
  const pow = await Pow.deploy();
  await pow.deployed();

  console.log("Pow deployed to:", pow.address);

  //await hre.network.provider.send("evm_setAutomine", [true]);
  //await hre.network.provider.send("evm_setIntervalMining", [15000]);

  var nonce = -1;
  for(var i = 0; i < 10000; i++) {
    await showBlockNumber();
    while(true) {
      nonce += 1;
      if(await pow.checkNonce(ACCOUNT, nonce)) {
        break;
      }
    }
    console.log(`attempting to mine ${nonce}`);
    const mintTx = await pow.mint(ACCOUNT, nonce);
    const txResult = await mintTx.wait();
    const balance = await pow.balanceOf(ACCOUNT);
    // todo: something obviously off about the gas calc
    console.log(`mined with nonce ${nonce} currently have ${balance} gas cost \$${getApproxGasCost(txResult)}`)
  }
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
