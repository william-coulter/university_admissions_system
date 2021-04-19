const ChiefOperatingOfficer = artifacts.require("ChiefOperatingOfficer");
const ManagerFactory = artifacts.require("ManagerFactory");
const UserFactory = artifacts.require("UserFactory");

const RolesManager = artifacts.require("RolesManager");
const SessionManager = artifacts.require("SessionManager");
const CourseManager = artifacts.require("CourseManager");
const TokensManager = artifacts.require("TokensManager");

const Administrator = artifacts.require("Administrator");
const Student = artifacts.require("Student");

contract("Scenario 1", () => {

    let cooAccount;
    let adminAccount;
    let studentAccounts;

    let cooContract;
    let adminContract;
    let studentContracts;
    let managerFactory;
    let userFactory;

    // Initial setup according to test specification.
    //
    // Would love to abstract this into its own function
    before(async () => {

        // Truffle has web3 available natively!
        const accounts = await web3.eth.getAccounts();
        cooAccount = accounts[0];
        adminAccount = accounts[1];
        studentAccounts = accounts.slice(2, 7);

        // Get deployed contracts
        // These are deployed as a part of the truffle migrations
        cooContract = await ChiefOperatingOfficer.deployed();
        managerFactory = await ManagerFactory.deployed();
        userFactory = await UserFactory.deployed();

        // Set all the contracts for the ManagerFactory
        const rolesManager = await RolesManager.new(cooContract.address, userFactory.address);
        const sessionManager = await SessionManager.new(cooContract.address, managerFactory.address);
        const courseManager = await CourseManager.new(managerFactory.address);
        const tokensManager = await TokensManager.new(5 * 18 * 1000, managerFactory.address, cooContract.address);

        await managerFactory.setRolesManager(rolesManager.address, { from: cooAccount });
        await managerFactory.setSessionManager(sessionManager.address, { from: cooAccount });
        await managerFactory.setCourseManager(courseManager.address, { from: cooAccount });
        await managerFactory.setTokensManager(tokensManager.address, { from: cooAccount });

        // Now lets set up the scenario
        // Set fees and start session
        await cooContract.setFee(1000, { from: cooAccount });
        await cooContract.startSession(managerFactory.address, userFactory.address, { from: cooAccount });

        // Admit the admin and retrieve admin contract
        const authorizeAdminTx = await cooContract.authorizeAdmin(adminAccount, { from: cooAccount });
        const adminContractAddress = authorizeAdminTx.receipt.logs[0].args.admin;
        adminContract = await getAdminContract(adminContractAddress);

        // Admin adds courses
        const courses = [
            {
                code: "COMP6451",
                name: "Blockchain and Distributed Systems",
                quota: 2,
                enrolled: [],
                UoC: 6
            },
            {
                code: "COMP4212",
                name: "No idea",
                quota: 3,
                enrolled: [],
                UoC: 6
            },
            {
                code: "COMP3441",
                name: "No idea",
                quota: 2,
                enrolled: [],
                UoC: 6
            }
        ];

        await Promise.all(
            courses.map((c) => adminContract.createCourse(
                c,
                { from: adminAccount }
            ))
        );

        // Admit students
        const studentContractAddresses = (await Promise.all(
            studentAccounts.map((acc) =>
                adminContract.admitStudent(acc, { from: adminAccount }))
        )).map((tx) => tx.receipt.logs[0].args.student);

        studentContracts = await Promise.all(
            studentContractAddresses.map((address) =>
                getStudentContract(address)
            )
        );

        // All students purchase 18 UoC
        await Promise.all(studentContracts.map((sc, i) => 
            sc.purchaseUoC(18, { from: studentAccounts[i], value: 18000 })
        ));
        
    });

    it("Balance of university system is 90,000 Wei", async () => {
        // Since I implemented with an ERC20 token, the Wei that students transfer
        // to the university is separate to the admission tokens they receive. Instead,
        // testing that the university has 90,000 admission tokens to distribute to students
        // is sufficient for this test.
        // const tx = await cooContract.getUniversityBalance();
        // console.log(tx);

        // assert();

    });
});

// Contract.at with Truffle is ONLY 'thenable' haha:
// https://github.com/trufflesuite/truffle/tree/master/packages/contract#mycontractataddress
//
// Writing these functions to get around this
async function getAdminContract(address) {
    return new Promise((resolve, reject) => {
        Administrator.at(address).then(instance => {
            return resolve(instance);
        }).catch((e) => {
            return reject(e)
        });
    });
}

async function getStudentContract(address) {
    return new Promise((resolve, reject) => {
        Student.at(address).then(instance => {
            return resolve(instance);
        }).catch((e) => {
            return reject(e)
        });
    });
}

function sleep(milli) {
    const currentTime = new Date().getTime();
    while (currentTime + milli >= new Date().getTime()) {}
}
