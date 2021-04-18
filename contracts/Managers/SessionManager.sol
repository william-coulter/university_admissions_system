// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./RoundManager.sol";
import "./RolesManager.sol";
import "./CourseManager.sol";
import "../Users/ChiefOperatingOfficer.sol";

contract SessionManager {

    uint256 internal constant oneDay = 1 days;
    
    ChiefOperatingOfficer internal _COO;
    RoundManager internal _currRound;
    RolesManager internal _rolesManager;
    TokensManager internal _tokensManager;
    CourseManager internal _courseManager;

    uint256 internal _deadline;

    constructor(ChiefOperatingOfficer _coo) {
        _COO = _coo;

        _currRound = newRound();
        _rolesManager = _COO.getRolesManager();
        _tokensManager = _COO.getTokensManager();
        _courseManager = _COO.getCourseManager();
        
        _deadline = block.timestamp + oneDay;
    }

    /**
     * Requires that the caller is the chief operating officer
     */
    modifier requiresChiefOperatingOfficer {
        require(
            msg.sender == address(_COO)
            , "Only the Chief Operating Officer can call this function"
        );
        _;
    }

    /**
     * Requires that the caller is an admin
     */
    modifier requiresAdmin {
        require(
            _rolesManager.hasRole(msg.sender, RolesManager.Roles.Admin)
            , "Only an admin can call this function"
        );
        _;
    }

    /**
     * Requires that the caller is a student
     */
    modifier requiresStudent {
        require(
            _rolesManager.hasRole(msg.sender, RolesManager.Roles.Student)
            , "Only a student can call this function"
        );
        _;
    }

    /**
     * Starts a new round.
     */
    function newRound() internal returns (RoundManager) {
        return new RoundManager(_COO);
    }

    /**
     * Ensures that the deadline has passed and starts a new round if required.
     *
     * Returns true if a new round was started
     */
    function executeRound() public requiresChiefOperatingOfficer returns (bool) {
        require(
            block.timestamp > _deadline
            , "Cannot execute round since deadline is not reached" 
        );

        bool startNewRound = _currRound.executeRound();

        if (startNewRound) {
            _currRound.kill();
            _currRound = newRound();
            _deadline = block.timestamp + oneDay;
        }

        return startNewRound;
    }

    /**
     * Sets the deadline. Deadline cannot be before now.
     */
    function setDeadline(uint256 newDeadline) public requiresAdmin {
        require(
            newDeadline > block.timestamp
            , "Cannot set deadline to before current time"
        );

        _deadline = newDeadline;
    }

    /**
     * Returns the current round.
     */
    function getCurrRound() public view returns (RoundManager) {
        return _currRound;
    }
}
