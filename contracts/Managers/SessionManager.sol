// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./RoundManager.sol";
import "./RolesManager.sol";

contract SessionManager {

    uint256 internal constant oneDay = 1 days;
    
    address internal _COO;
    RoundManager internal _currRound;
    RolesManager internal _rolesManager;

    uint256 internal _deadline;

    constructor(address _coo, RoundManager _rnd, RolesManager _rls) {
        _currRound = _rnd;
        _rolesManager = _rls;
        _COO = _coo;
        _deadline = block.timestamp + oneDay;
    }

    /**
     * Requires that the caller is the chief operating officer
     */
    modifier requiresChiefOperatingOfficer {
        require(
            msg.sender == _COO
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

    // TODO:
    // function newRound() internal returns (RoundManager) {
    //     return _COO.startNewRound();
    //      _deadline = block.timestamp + oneDay;
    // }

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
            // TODO: _currRound = newRound();
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
     *
     * This function is used by students so that they can add their bids.
     */
    function getCurrRound() public view requiresStudent returns (RoundManager) {
        return _currRound;
    }
}
