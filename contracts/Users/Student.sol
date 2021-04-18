// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../Managers/RolesManager.sol";
import "../Managers/RoundManager.sol";
import "../Managers/SessionManager.sol";
import "../Managers/CourseManager.sol";
import "../Managers/TokensManager.sol";
import "./ChiefOperatingOfficer.sol";

contract Student {

    struct Enrolment {
        string code;
        uint8 UoC;
    }

    ChiefOperatingOfficer _COO;

    RolesManager internal _rolesManager;
    CourseManager internal _courseManager;
    SessionManager internal _sessionManager;
    TokensManager internal _tokensManager;
    RoundManager internal _roundManager;

    address internal _owner;
    uint8 internal _purchasedUoC = 0;
    RoundManager.Bid[] _pendingBids;
    Enrolment[] _enrolments;

    constructor(ChiefOperatingOfficer _coo, address owner) {
        _owner = owner;
        _COO = _coo;

        _rolesManager = _COO.getRolesManager();
        _courseManager = _COO.getCourseManager();
        _sessionManager = _COO.getSessionManager();
        _tokensManager = _COO.getTokensManager();
        _roundManager = _COO.getRoundManager();
    }

    /**
     * Requires the student to call the method
     */
    modifier requiresOwner {
        require(
            msg.sender == _owner
            , "Student: Only the owner can call this function"
        );
        _;
    }

    /**
     * Requires the roundmanager can call this method
     */
    modifier requiresRoundManager {
        require(
            msg.sender == _owner
            , "Student: Only the Round Manager can call this function"
        );
        _;
    }

    /**
     * Gets the student allowance
     */
    function getAllowance() internal view returns (uint256) {
        return _tokensManager.allowance(address(_tokensManager), address(this));
    }

    /**
     * Purchases a desired amount of UoC
     */
    function purchaseUoC(uint8 desiredUoC, uint256 amount) public {
        bool response = _tokensManager.purchaseUoC{value: amount}(address(this), desiredUoC);

        require(
            response
            , "Student: Could not purchase UoC"
        );

        _purchasedUoC += desiredUoC;
    }

    /**
     * Adds a bid
     */
    function addBid(RoundManager.Bid memory bid) public requiresOwner {
        checkValidBid(bid);
        require(
            _tokensManager.transferFrom(address(this), address(_roundManager), bid.amount)
            , "Student: Could not transfer allowance to RoundManager to add a bid"
        );
        _pendingBids.push(bid);
    }

    /**
     * Throws errors if the bid is not valid
     */
    function checkValidBid(RoundManager.Bid memory bid) internal view {
        // check allowance
        require(
            getAllowance() > bid.amount
            , "Student: Not enough admission tokens to add bid."
        );

        // check not enrolling in more UoC than purchased
        uint8 UoCPending = 0;
        for (uint256 i = 0; i < _pendingBids.length; i++) {
            UoCPending += _pendingBids[i].course.UoC;
        }

        require(
            UoCPending + bid.course.UoC <= _purchasedUoC
            , "Student: Cannot bid on more UoC than purchased"
        );
    }

    /**
     * Called by the RoundManager when a bid is successful
     */
    function bidSuccessful(Enrolment memory enrolment) public requiresRoundManager {
        _purchasedUoC -= enrolment.UoC;

        bool removedFromPending = false;
        for (uint256 i = 0; i < _pendingBids.length; i++) {
            if (keccak256(bytes(_pendingBids[i].course.code)) == keccak256(bytes(enrolment.code))) {
                delete _pendingBids[i];
                removedFromPending = true;
                break;
            }
        }

        require(
            removedFromPending
            , "Student: Error: Could not remove bid from pending bid"
        );

        _enrolments.push(enrolment);
    }

    /**
     * Called by the RoundManager when a bid is successful
     */
    function bidUnsuccessful(Enrolment memory enrolment) public requiresRoundManager {
        bool removedFromPending = false;
        for (uint256 i = 0; i < _pendingBids.length; i++) {
            if (keccak256(bytes(_pendingBids[i].course.code)) == keccak256(bytes(enrolment.code))) {
                delete _pendingBids[i];
                removedFromPending = true;
                break;
            }
        }

        require(
            removedFromPending
            , "Student: Error: Could not remove bid from pending bid"
        );
    }
}
