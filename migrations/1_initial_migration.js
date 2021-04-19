const ChiefOperatingOfficer = artifacts.require("ChiefOperatingOfficer");
const ManagerFactory = artifacts.require("ManagerFactory");
const UserFactory = artifacts.require("UserFactory");

module.exports = function (deployer) {
  deployer.deploy(ChiefOperatingOfficer).then((coo) => {
      return deployer.deploy(ManagerFactory, coo.address).then((mf) => {
        return deployer.deploy(UserFactory, mf.address);
      });
  });
};
