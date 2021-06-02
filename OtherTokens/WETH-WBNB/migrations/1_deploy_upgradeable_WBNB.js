const WBNB = artifacts.require("./Binance/WBNB");

module.exports = function (deployer) {
  deployer.deploy(WBNB);
};
