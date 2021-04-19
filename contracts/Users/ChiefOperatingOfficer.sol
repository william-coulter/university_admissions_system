// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../Factories/ManagerFactory.sol";
import "../Factories/UserFactory.sol";

contract ChiefOperatingOfficer {

    /**
     * Events
     */
    event SessionStarted();
    event AuthorizedAdmin(address admin);

    /*
     * Internal parameters
     */
    address internal _managerFactory;
    address internal _userFactory;

    address internal _owner;
    uint256 internal _tokenFee = 100;
    bool internal _sessionStarted = false;

    /**
     * Constructor
     */
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

        emit SessionStarted();
    }

    /**
     * Returns true if a new round was started (students missed out on bids)
     */
    function executeRound() external requiresOwner returns (bool) {
        return ManagerFactory(_managerFactory).getSessionManager().executeRound();
    }

    /**
     * Changes the owner of the COO
     */
    function changeOwner(address newOwner) public requiresOwner {
        _owner = newOwner;
    }

    /**
     * Changes the owner of the COO
     */
    function getOwner() public view returns (address) {
        return _owner;
    }

    /**
     * Authorizes and admin
     */
    function authorizeAdmin(address admin) public requiresOwner requireSessionStart returns (address) {
        address adminContractAddress = ManagerFactory(_managerFactory).getRolesManager().authorize(admin, RolesManager.Roles.Admin);
        emit AuthorizedAdmin(adminContractAddress);
        return adminContractAddress;
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

    /**
     * Gets university tokens
     */
    function getUniversityBalance() external view returns (uint256) {
        return ManagerFactory(_managerFactory).getTokensManager().balanceOf(address(this));
    }

    /**
     * TODO: This should be restricted to students only
     */
    function purchaseUoC(address spender, uint8 UoC) public payable requireSessionStart returns (bool) {
        uint256 UoCFee = getFee();
        uint256 requiredWei = UoC * UoCFee;

        require(
            msg.value >= requiredWei
            , "TokensManager: Not enough Wei sent to purchase UoC"
        );

        require(
            msg.value == requiredWei
            , "TokensManager: Too much Wei sent to purchase UoC"
        );

        return ManagerFactory(_managerFactory).getTokensManager().approve(spender, UoC * UoCFee);
    }
}
