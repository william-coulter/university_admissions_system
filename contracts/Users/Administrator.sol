// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../Managers/RolesManager.sol";
import "../Managers/SessionManager.sol";
import "../Managers/CourseManager.sol";
import "./ChiefOperatingOfficer.sol";

contract Administrator {
    
    ChiefOperatingOfficer _COO;

    RolesManager internal _rolesManager;
    CourseManager internal _courseManager;
    SessionManager internal _sessionManager;

    address internal _owner;

    constructor(ChiefOperatingOfficer _coo, address owner) {
        _owner = owner;
        _COO = _coo;

        _rolesManager = _COO.getRolesManager();
        _courseManager = _COO.getCourseManager();
        _sessionManager = _COO.getSessionManager();
    }

    /**
     * Requires the admin to call the method
     */
    modifier requiresOwner {
        require(
            msg.sender == _owner
            , "Administrator: Only the owner can call this function"
        );
        _;
    }

    /**
     * Admits a student. Returns the address of the newly deployed Student contract.
     */
    function admitStudent(address student) public requiresOwner returns (address) {
        return _rolesManager.authorize(student, RolesManager.Roles.Student);
    }

    /**
     * Revoked student permissions. Doesn't destroy the contract 
     */
    function revokeStudent(/*Student*/ address student) public requiresOwner returns (address) {
        return _rolesManager.authorize(student, RolesManager.Roles.Revoked);
    }

    /**
     * Creates a course
     */
    function createCourse(CourseManager.Course memory course) public requiresOwner {
        _courseManager.addCourse(course);
    }

    /**
     * Sets a new course quota
     */
    function setCourseQuota(string memory code, uint16 newQuota) public requiresOwner {
        _courseManager.setQuota(code, newQuota);
    }

    /**
     * Sets the deadline for the session
     */
    function setDeadline(uint256 newDeadline) public requiresOwner {
        _sessionManager.setDeadline(newDeadline);
    }
}
