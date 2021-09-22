const { expect } = require("chai");
const { ethers } = require("hardhat");

const ACCOUNT = "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266";

describe("Pow", function () {
  it("Should mint under friendly case", async function () {
    const Pow = await ethers.getContractFactory("Pow");
    const pow = await Pow.deploy();
    await pow.deployed();

    const beforeEase = await pow.getEase();
    const beforeDifficultyIncrement = await pow.getDifficultyIncrement();
    const mintTx = await pow.mint(ACCOUNT, 11);
    await mintTx.wait();
    const actualBalance = await pow.balanceOf(ACCOUNT);
    const afterEase = await pow.getEase();
    const afterDifficultyIncrement = await pow.getDifficultyIncrement();

    expect(beforeDifficultyIncrement.eq(afterDifficultyIncrement)).to.equal(true);
    expect(actualBalance).to.equal(1);
    expect(afterEase.eq(beforeEase.div(ethers.BigNumber.from(16)))).to.equal(true);
  });
});
