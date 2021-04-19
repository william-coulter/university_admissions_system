// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../Managers/TokensManager.sol";
import "../Managers/RolesManager.sol";
import "../Managers/SessionManager.sol";
import "../Managers/RoundManager.sol";
import "../Managers/CourseManager.sol";

/**
 * Responsible for deploying and returning system managers
 *
 * This contract isn't really a Factory anymore. To reduce contract
 * size for deployment I had to change all the creators to setters.
 */
contract ManagerFactory {
    address internal _coo;
    address internal _tokensManager;
    address internal _rolesManager;
    address internal _sessionManager;
    address internal _courseManager;

    /**
     * Constructing this deploys all managers
     */
    constructor(address coo) {
        _coo = coo;
    }

    /**
     * Requires that the COO calls this function
     */
    modifier requiresCOO {
        require(
            msg.sender == _coo
            , "Only the Chief Operating Officer can call this function"
        );
        _;
    }

    /**
     * Set all the managers
     *
     */
    function setTokensManager(TokensManager tks) public requiresCOO {
        _tokensManager = address(tks);
    }

    function setRolesManager(RolesManager rls) public requiresCOO {
        _rolesManager = address(rls);
    }

    function setSessionManager(SessionManager ssm) public requiresCOO {
        _sessionManager = address(ssm);
    }

    function setCourseManager(CourseManager crs) public requiresCOO {
        _courseManager = address(crs);
    }

    /**
     * Getters for the Managers
     *
     * Anyone can call these getters but all methods on the managers are permissioned
     */
    function getTokensManager() public view returns (TokensManager) {
        return TokensManager(_tokensManager);
    }

    function getRolesManager() public view returns (RolesManager) {
        return RolesManager(_rolesManager);
    }

    function getSessionManager() public view returns (SessionManager) {
        return SessionManager(_sessionManager);
    }

    function getRoundManager() public view returns (RoundManager) {
        return getSessionManager().getCurrRound();
    }

    function getCourseManager() public view returns (CourseManager) {
        return CourseManager(_courseManager);
    }
}
