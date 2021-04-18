// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../Managers/TokensManager.sol";
import "../Managers/RolesManager.sol";
import "../Managers/SessionManager.sol";
import "../Managers/RoundManager.sol";
import "../Managers/CourseManager.sol";

contract ChiefOperatingOfficer {

    // The COO deploys all the managers
    TokensManager internal _tokensManager;
    RolesManager internal _rolesManager;
    SessionManager internal _sessionManager;
    CourseManager internal _courseManager;

    address internal _owner;
    uint256 internal _tokenFee;

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
     * Starts the session
     */
    function startSession() public requiresOwner {
        require(
            address(_sessionManager) == address(0)
            , "Session has already started"
        );

        // Deploy all of the managers
        _tokensManager = new TokensManager(5 * 18 * 1000, this);
        _rolesManager = new RolesManager(this);
        _sessionManager = new SessionManager(this);
        _courseManager = new CourseManager(this);
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
    function authorizeAdmin(address admin) public requiresOwner returns (address) {
        return _rolesManager.authorize(admin, RolesManager.Roles.Admin);
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
    function getFee() public returns (uint256) {
        return _tokenFee;
    }

    /**
     * Getters for the Managers
     *
     * Anyone can call these getters but all methods on the managers are permissioned
     */
    function getTokensManager() public view returns (TokensManager) {
        return _tokensManager;
    }

    function getRolesManager() public view returns (RolesManager) {
        return _rolesManager;
    }

    function getSessionManager() public view returns (SessionManager) {
        return _sessionManager;
    }

    function getRoundManager() public view returns (RoundManager) {
        return _sessionManager.getCurrRound();
    }

    function getCourseManager() public view returns (CourseManager) {
        return _courseManager;
    }
}
