var Asset = artifacts.require("./Asset.sol");

module.exports = function(deployer) {
  deployer.deploy(Asset, 1, "Screwdriver", 10, 1);
};
