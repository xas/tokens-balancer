const Ratio = artifacts.require("Ratio");
const Dai = artifacts.require("dai/dai");
const Weth = artifacts.require("weth/weth");
const Router = artifacts.require("router/router");

module.exports = async function (deployer) {
  await deployer.deploy(Dai);
  await deployer.deploy(Weth);
  await deployer.deploy(Router);
  let instanceDai = await Dai.deployed();
  let instanceWeth = await Weth.deployed();
  let instanceRouter = await Router.deployed();
  return deployer.deploy(Ratio, instanceWeth.address, instanceDai.address, instanceRouter.address, 20);
};
