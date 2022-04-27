const FlexStaking = artifacts.require("FlexStaking.sol");

module.exports = function (deployer) {
  deployer.deploy(FlexStaking);
};