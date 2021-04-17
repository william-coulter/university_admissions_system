// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./SessionManager.sol";
import "./RolesManager.sol";

contract CourseManager {

    struct Course {
        string code;
        string name;
        uint16 quota;
        address[] enrolled;
        uint8 UoC;
    }
    
    SessionManager internal _sessionManager;
    RolesManager internal _rolesManager;

    // mapping from course codes to their courses, keeping
    // track of all the course codes added.\
    mapping (string => Course) _courses;
    string[] _codes;

    constructor(SessionManager _ssm, RolesManager _rls) {
        _sessionManager = _ssm;
        _rolesManager = _rls;
    }

     /**
     * Requires that the sender is the Round Manager
     */
    modifier requiresRoundManager {
        RoundManager roundManager = _sessionManager.getCurrRound();

        require(
            msg.sender == address(roundManager)
            , "Only an admin can call this function"
        );
        _;
     }

    /**
     * Requires that the sender is an admin
     */
    modifier requiresAdmin {        
        require(
            _rolesManager.hasRole(msg.sender, RolesManager.Roles.Admin)
            , "Only the round manager can call this function"
        );
        _;
     }

    /**
     * Adds a course to the _courses mapping. Requires that the course did not previously exist
     */
    function addCourse(Course memory course) public requiresAdmin {
        require(
            !courseExists(course.code)
            , "Course already exists"
        );

        _courses[course.code] = course;
        _codes.push(course.code);
    }

    /**
     * Sets a new quota for a course. Requires that the course exists.
     */
    function setQuota(string memory code, uint16 newQuota) public requiresAdmin {
        require(
            courseExists(code)
            , "Course does not exist"
        );

        _courses[code].quota = newQuota;
    }

    /**
     * The provided course code should always exist, but there is a check anyway
     */
    function setEnrolment(string memory course, address[] memory newEnrolment) public requiresRoundManager {
        require(
            keccak256(bytes(_courses[course].code)) != keccak256(bytes(""))
            , "Provided course does not exist"
        );

        _courses[course].enrolled = newEnrolment;
    }

    /**
     * Returns true if the course exists.
     */
    function courseExists(string memory code) internal view returns (bool) {
        return keccak256(bytes(_courses[code].code)) != keccak256(bytes(""));
    }
}
