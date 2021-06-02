const BEP20Ethereum= artifacts.require("BEP20Ethereum");

module.exports = function (deployer) {
  deployer.deploy(BEP20Ethereum);
};
