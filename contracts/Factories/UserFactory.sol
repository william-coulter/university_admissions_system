// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../Users/Administrator.sol";
import "../Users/Student.sol";
import "./ManagerFactory.sol";

/**
 * Responsible for deploying and returning system managers
 */
contract UserFactory {
    address internal _managerFactory;

    constructor(address managerFactory) {
        _managerFactory = managerFactory;
    }

    modifier requiresRolesManager {
        require(
            msg.sender == address(ManagerFactory(_managerFactory).getRolesManager())
            , "UserFactory: Only the Roles Manager can call this function"
        );
        _;
    }

    /**
     * Creates students and administrators
     */
    function createAdmin(address owner) public requiresRolesManager returns (address) {
        return address(new Administrator(_managerFactory, owner));
    }
    
    function createStudent(address owner) public requiresRolesManager returns (address) {
        return address(new Student(_managerFactory, owner));
    }
}
