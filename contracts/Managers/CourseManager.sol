// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./RoundManager.sol";
import "./SessionManager.sol";

contract CourseManager {

    struct Course {
        string code;
        string name;
        uint16 quota;
        address[] enrolled;
        uint8 UoC;
    }

    RoundManager internal _roundManager;
    SessionManager internal _sessionManager;

    mapping (string => Course) _courses;

    constructor(RoundManager _rnd, SessionManager _ssm) {
        _roundManager = _rnd;
        _sessionManager = _ssm;
    }

    /**
     * Requires that the sender is the Session Manager
     */
     modifier requiresSessionManager {
         require(
             msg.sender == address(_sessionManager)
             , "Only the session manager can call this function"
         );
         _;
     }

     /**
     * Requires that the sender is the Round Manager
     */
    modifier requiresRoundManager {
         require(
             msg.sender == address(_roundManager)
             , "Only the round manager can call this function"
         );
         _;
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


    function setRoundManager(RoundManager rnd) public requiresSessionManager {
        _roundManager = rnd;
    }
}
