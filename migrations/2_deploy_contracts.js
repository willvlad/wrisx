var WrisxToken = artifacts.require("WrisxToken");

module.exports = function(deployer) {
  deployer.deploy(WrisxToken, 'n', 't', 18, 10000, 1);
};

