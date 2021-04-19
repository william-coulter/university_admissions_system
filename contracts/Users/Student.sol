// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../Factories/ManagerFactory.sol";
import "../Managers/RoundManager.sol";
import "../Managers/CourseManager.sol";

contract Student {

    struct Enrolment {
        string code;
        uint8 UoC;
    }

    address internal _manager;

    address internal _owner;
    uint8 internal _purchasedUoC = 0;
    RoundManager.Bid[] _pendingBids;
    Enrolment[] _enrolments;

    constructor(address manager, address owner) {
        _manager = manager;
        _owner = owner;
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
            msg.sender == address(ManagerFactory(_manager).getRoundManager())
            , "Student: Only the Round Manager can call this function"
        );
        _;
    }

    /**
     * Gets the student allowance
     */
    function getAllowance() internal view returns (uint256) {
        return ManagerFactory(_manager).getTokensManager().allowance(address(ManagerFactory(_manager).getTokensManager()), address(this));
    }

    /**
     * Purchases a desired amount of UoC
     */
    function purchaseUoC(uint8 desiredUoC, uint256 amount) public requiresOwner {
        bool response = ManagerFactory(_manager).getTokensManager().purchaseUoC{value: amount}(address(this), desiredUoC);

        require(
            response
            , "Student: Could not purchase UoC"
        );

        _purchasedUoC += desiredUoC;
    }

    /**
     * Adds a bid, checking that it's valid and transferring allowance to RoundManager
     */
    function addBid(string memory code, uint256 amount) public requiresOwner {

        RoundManager.Bid memory newBid = createBid(code, amount);

        require(
            ManagerFactory(_manager).getTokensManager().transferFrom(address(this), address(ManagerFactory(_manager).getRoundManager()), newBid.amount)
            , "Student: Could not transfer allowance to RoundManager to add a bid"
        );

        _pendingBids.push(newBid);
    }

    /**
     * Alters an existing bid.
     * This removes the bid and then attempts to add the new one.
     *
     * The 'code' provided must be in the pending bids.
     */
    function alterBid(string memory code, uint256 newAmount) public requiresOwner {
        bool isExistingBid = false;
        RoundManager.Bid memory currBid;

        for (uint256 i; i < _pendingBids.length; i++) {
            if (keccak256(bytes(_pendingBids[i].course.code)) == keccak256(bytes(code))) {
                isExistingBid = true;
                currBid = _pendingBids[i];
                delete _pendingBids[i];

                break;
            }
        }

        require(
            isExistingBid
            , "Student: Bid to alter does not exist"
        );

        // Transfers allowance back from the RoundManager back to the Student
        ManagerFactory(_manager).getRoundManager().removeBid(code, this);
        addBid(code, newAmount);
    }

    /**
     * Removes a bid, transferring tokens back to this student
     */
    function removeBid(string memory code) public requiresOwner {
        bool isExistingBid = false;
        RoundManager.Bid memory currBid;

        for (uint256 i; i < _pendingBids.length; i++) {
            if (keccak256(bytes(_pendingBids[i].course.code)) == keccak256(bytes((code)))) {
                isExistingBid = true;
                currBid = _pendingBids[i];
                delete _pendingBids[i];

                break;
            }
        }

        require(
            isExistingBid
            , "Student: Bid to delete does not exist"
        );

        ManagerFactory(_manager).getRoundManager().removeBid(code, this);
    }

    /**
     * Transfers tokens to another student
     */
    function transfer(uint256 amount, Student student) public requiresOwner {
        ManagerFactory(_manager).getTokensManager().transferToStudent(address(student), amount);
    }

    /**
     * Throws errors if the bid is not valid and cannot be created
     */
    function createBid(string memory code, uint256 amount) internal view requiresOwner returns (RoundManager.Bid memory) {
        // This method checks that the course exists
        CourseManager.Course memory course = ManagerFactory(_manager).getCourseManager().getCourse(code);
        RoundManager.Bid memory newBid = RoundManager.Bid(amount, course, this, block.timestamp);

        // check allowance
        require(
            getAllowance() > newBid.amount
            , "Student: Not enough admission tokens to add bid."
        );

        // check not enrolling in more UoC than purchased
        uint8 UoCPending = 0;
        for (uint256 i = 0; i < _pendingBids.length; i++) {
            UoCPending += _pendingBids[i].course.UoC;
        }

        require(
            UoCPending + newBid.course.UoC <= _purchasedUoC
            , "Student: Cannot bid on more UoC than purchased"
        );

        return newBid;
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
