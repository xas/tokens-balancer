const DaiContract = artifacts.require("Dai");
const WethContract = artifacts.require("Weth");
const RouterContract = artifacts.require("Router");
const RatioContract = artifacts.require("Ratio");
var BN = web3.utils.BN;
var Utils = web3.utils;

contract("tokens balancer swap test", async accounts => {
  it("should give some balance", async () => {
    // Get initial balances of first and second account.
    const account_one = accounts[0];

    // get the instance for the dai token
    const daiInstance = await DaiContract.deployed();
    // get the instance for the dai token
    const wethInstance = await WethContract.deployed();

    // begin with 5 WETH + 5000 DAI
    const weiAmount = Utils.toWei('7');
    const daiAmount = Utils.toWei('2000');

    // get weth to the personnal account
    await web3.eth.sendTransaction({from:account_one, to:wethInstance.address, value: weiAmount});
    // get dai to the personnal account
    await daiInstance.mint(account_one, daiAmount, { from: account_one });

    let preWethBalance = await wethInstance.balanceOf.call(account_one);
    let preDaiBalance = await daiInstance.balanceOf.call(account_one);
    // assert the personnal account has weth & dai
    assert.equal(preWethBalance.toString(), weiAmount);
    assert.equal(preDaiBalance.toString(), daiAmount);
  });

  it("add some tokens to the contract", async () =>{
    const account_one = accounts[0];

    // get the instance for the dai token
    const daiInstance = await DaiContract.deployed();
    // get the instance for the dai token
    const wethInstance = await WethContract.deployed();
    // get the instance for the ration contract
    const gInst = await RatioContract.deployed();

    // begin with 5 WETH + 5000 DAI
    const weiAmount = web3.utils.toWei('5');
    const daiAmount = web3.utils.toWei('2000');

    // transfer weth to the contract
    await wethInstance.transfer(gInst.address, weiAmount, { from: account_one });
    // transfer dai to the contract
    await daiInstance.transfer(gInst.address, daiAmount, { from: account_one });

    let preWethBalance = await wethInstance.balanceOf.call(gInst.address);
    let preDaiBalance = await daiInstance.balanceOf.call(gInst.address);
    // assert the ratio contract has weth and dai
    assert.equal(preWethBalance.toString(), weiAmount);
    assert.equal(preDaiBalance.toString(), daiAmount);
  });

  it("first try with swap from eth -> dai at 1790", async () => {
    // So for the test we have 5 eth and 2000 dai
    // We ask for a price market of 1 eth = 1790 dai
    // Get initial balances of first and second account.
    const account_one = accounts[0];
    const account_two = accounts[1];

    // get the instance for the dai token
    const daiInstance = await DaiContract.deployed();
    // get the instance for the dai token
    const wethInstance = await WethContract.deployed();
    // get the instance for the router
    const uniInstance = await RouterContract.deployed();
    // get the instance for the ration contract
    const gInst = await RatioContract.deployed();

    // begin with 5 WETH + 20000 DAI
    const weiAmount = web3.utils.toWei('10');
    const daiAmount = web3.utils.toWei('20000');

    // get dai to uniswap
    await daiInstance.mint(uniInstance.address, daiAmount, { from: account_one });

    // get weth
    await web3.eth.sendTransaction({from:account_two, to:wethInstance.address, value: weiAmount});
    // transfer weth to uniswap
    await wethInstance.transfer(uniInstance.address, weiAmount, { from: account_two });

    // define the uniswap pair
    await uniInstance.setPath(wethInstance.address, daiInstance.address);
    // hack to suppose the market price is 1 eth == 1790 dai
    await uniInstance.setRatio(1790);
    
    await gInst.sync(1790, { from: account_one });

    let postWethBalance = await wethInstance.balanceOf.call(gInst.address);
    let postDaiBalance = await daiInstance.balanceOf.call(gInst.address);

    assert.equal(postWethBalance.toString(), '4893854748603351956');
    assert.equal(postDaiBalance.toString(), '2189999999999999998760');
  });


  it("then swap again from dai -> eth at 500", async () => {
    // So for the test we have 5 eth and 2000 dai
    // We ask for a price market of 1 eth = 500 dai
    // Get initial balances of first and second account.
    const account_one = accounts[0];
    const account_two = accounts[1];

    // get the instance for the dai token
    const daiInstance = await DaiContract.deployed();
    // get the instance for the dai token
    const wethInstance = await WethContract.deployed();
    // get the instance for the router
    const uniInstance = await RouterContract.deployed();
    // get the instance for the ration contract
    const gInst = await RatioContract.deployed();

    // begin with 5 WETH + 5000 DAI
    const weiAmount = web3.utils.toWei('10');
    const daiAmount = web3.utils.toWei('20000');

    // get dai to uniswap
    await daiInstance.mint(uniInstance.address, daiAmount, { from: account_one });

    // get weth
    await web3.eth.sendTransaction({from:account_two, to:wethInstance.address, value: weiAmount});
    // transfer weth to uniswap
    await wethInstance.transfer(uniInstance.address, weiAmount, { from: account_two });

    // define the uniswap pair
    await uniInstance.setPath(wethInstance.address, daiInstance.address);
    // hack to suppose the market price is 1 eth == 500 dai
    await uniInstance.setRatio(500);
    
    await gInst.sync(500, { from: account_one });

    let postWethBalance = await wethInstance.balanceOf.call(gInst.address);
    let postDaiBalance = await daiInstance.balanceOf.call(gInst.address);

    assert.equal(postWethBalance.toString(), '7419083798882681563');
    assert.equal(postDaiBalance.toString(), '927385474860335195260');
  });
});