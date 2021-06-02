const BEP20USDT = artifacts.require("BEP20USDT");

module.exports = function (deployer) {
  deployer.deploy(BEP20USDT);
};
