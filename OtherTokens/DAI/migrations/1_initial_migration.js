const BEP20DAI= artifacts.require("BEP20DAI");

module.exports = function (deployer) {
  deployer.deploy(BEP20DAI);
};
