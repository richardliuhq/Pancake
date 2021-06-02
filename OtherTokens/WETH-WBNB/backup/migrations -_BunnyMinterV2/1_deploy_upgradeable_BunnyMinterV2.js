const minter= artifacts.require("./bunny/BunnyMinterV2");

module.exports = function (deployer) {
  deployer.deploy(minter);
};
