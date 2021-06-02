const BEP20TokenImplementation= artifacts.require("BEP20TokenImplementation");

module.exports = function (deployer) {
  deployer.deploy(BEP20TokenImplementation);
};
