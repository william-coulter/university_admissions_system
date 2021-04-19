// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../Factories/ManagerFactory.sol";
import "../Managers/CourseManager.sol";

contract Administrator {

    event AuthorizedStudent(address student);
    event CreatedCourse(string code);

    address internal _manager;
    address internal _owner;

    constructor(address manager, address owner) {
        _manager = manager;
        _owner = owner;
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
        address studentContract = ManagerFactory(_manager).getRolesManager().authorize(student, RolesManager.Roles.Student);
        emit AuthorizedStudent(studentContract);
        return studentContract;
    }

    /**
     * Revoked student permissions. Doesn't destroy the contract
     */
    function revokeStudent(address student) public requiresOwner returns (address) {
        return ManagerFactory(_manager).getRolesManager().authorize(student, RolesManager.Roles.Revoked);
    }

    /**
     * Creates a course
     */
    function createCourse(CourseManager.Course memory course) public requiresOwner {
        require(
            !ManagerFactory(_manager).getCourseManager().courseExists(course.code)
            , "Administrator: Course already exists"
        );

        ManagerFactory(_manager).getCourseManager().addCourse(course);
        emit CreatedCourse(course.code);
    }

    /**
     * Sets a new course quota
     */
    function setCourseQuota(string memory code, uint16 newQuota) public requiresOwner {
        ManagerFactory(_manager).getCourseManager().setQuota(code, newQuota);
    }

    /**
     * Sets the deadline for the session
     */
    function setDeadline(uint256 newDeadline) public requiresOwner {
        ManagerFactory(_manager).getSessionManager().setDeadline(newDeadline);
    }
}
