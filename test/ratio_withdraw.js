const DaiContract = artifacts.require("Dai");
const WethContract = artifacts.require("Weth");
const RouterContract = artifacts.require("Router");
const RatioContract = artifacts.require("Ratio");
var BN = web3.utils.BN;
var Utils = web3.utils;

contract("tokens balancer withdraw test", async accounts => {
  it("begin with some weth", async () => {
    // Get initial balances of first and second account.
    const account_one = accounts[0];

    // get the instance for the dai token
    const wethInstance = await WethContract.deployed();
    // get the instance for the ration contract
    const gInst = await RatioContract.deployed();

    // begin with 5 WETH
    const weiAmount = Utils.toWei('5');

    // get weth
    await web3.eth.sendTransaction({from:account_one, to:wethInstance.address, value: weiAmount});

    let preWethBalance = await wethInstance.balanceOf.call(gInst.address);
    assert.equal(preWethBalance.toString(), '0');

    // transfer weth to the contract
    await wethInstance.transfer(gInst.address, weiAmount, { from: account_one });

    let postWethBalance = await wethInstance.balanceOf.call(gInst.address);
    assert.equal(postWethBalance.toString(), weiAmount);
  });

  it("ask the contract to get back all the weth", async () =>{
    const account_one = accounts[0];

    // get the instance for the dai token
    const wethInstance = await WethContract.deployed();
    // get the instance for the ration contract
    const gInst = await RatioContract.deployed();

    // begin with 5 WETH
    const weiAmount = Utils.toWei('5');

    let preWethBalance = await wethInstance.balanceOf.call(account_one);
    assert.equal(preWethBalance.toString(), '0');

    // transfer weth to the contract
    await gInst.transferToken(wethInstance.address, { from: account_one });

    let postWethBalance = await wethInstance.balanceOf.call(account_one);
    assert.equal(postWethBalance.toString(), weiAmount);
  });

});