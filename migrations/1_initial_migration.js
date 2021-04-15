const Migrations = artifacts.require("Migrations");
const Sum = artifacts.require("Sum");

module.exports = function (deployer) {
  deployer.deploy(Migrations);
  deployer.deploy(Sum);
};

  