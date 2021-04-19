// import setupTests from "./utils/setupTests";

const ChiefOperatingOfficer = artifacts.require("ChiefOperatingOfficer");

contract("Scenario1", () => {
    it("should deploy the officer", async () => {
        const coo = await ChiefOperatingOfficer.deployed();
        console.log(coo);

        // const admin1 = await setupTests();
    });
});
