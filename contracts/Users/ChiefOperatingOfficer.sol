// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../Factories/ManagerFactory.sol";
import "../Factories/UserFactory.sol";

contract ChiefOperatingOfficer {

    address internal _managerFactory;
    address internal _userFactory;

    address internal _owner;
    uint256 internal _tokenFee = 100;
    bool internal _sessionStarted = false;

    constructor() {
        _owner = msg.sender;
    }

    /**
     * Requires the acting COO to call the method
     */
    modifier requiresOwner {
        require(
            msg.sender == _owner
            , "Only the acting Chief Operating Officer can call this method"
        );
        _;
    }

    /**
     * Requires that the session has started
     */
    modifier requireSessionStart {
        require(
            _sessionStarted
            , "Session has not started"
        );
        _;
    }

    /**
     * Starts the session
     */
    function startSession(ManagerFactory manager, UserFactory user) public requiresOwner {        
        require(
            !_sessionStarted
            , "Session has already started"
        );

        _sessionStarted = true;

        // Set factories
        _managerFactory = address(manager);
        _userFactory = address(user);
    }

    /**
     * Changes the owner of the COO
     */
    function changeOwner(address newOwner) public requiresOwner {
        _owner = newOwner;
    }

    /**
     * Authorizes and admin
     */
    function authorizeAdmin(address admin) public requiresOwner requireSessionStart returns (address) {
        return ManagerFactory(_managerFactory).getRolesManager().authorize(admin, RolesManager.Roles.Admin);
    }

    /**
     * TODO: Transfers the Wei out of the system
     */
    function transferOutOfSystem(/*uint256 amount*/) public view requiresOwner {
        return;
    }

    /**
     * Sets token fee for the session
     */
    function setFee(uint256 newFee) public requiresOwner {
        _tokenFee = newFee;
    }

    /**
     * Gets token fee for the session
     */
    function getFee() public view returns (uint256) {
        return _tokenFee;
    }
}
