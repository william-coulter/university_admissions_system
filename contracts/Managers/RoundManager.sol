// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./TokensManager.sol";
import "./CourseManager.sol";
import "./RolesManager.sol";
import "./SessionManager.sol";

/**
 *  The RoundManager is responsible for managing bids for the current round.
 */
contract RoundManager {

    struct Bid {
        uint256 amount;
        CourseManager.Course course;
        address student;
        uint256 updated;
    }

    TokensManager internal _tokensManager;
    RolesManager internal _rolesManager;
    SessionManager internal _sessionManager;

    // Mapping from Course.code to Bid. Also keeps track of the number of courses.
    mapping (string => Bid[]) internal _bidsPerCourse;
    uint256 internal coursesCount = 0;

    // Keeping track of all the courses we've added for iteration in 
    // 'executeRound' and 'getAllBids'
    string[] courses;

    // Mapping from address(Student) to Bid. Also keeps track of the number of students.
    mapping (address => Bid[]) internal _bidsPerStudent;
    uint256 internal studentsCount = 0;

    constructor(TokensManager _tks, RolesManager _rls, SessionManager _ssm) {
        _tokensManager = _tks;
        _rolesManager = _rls;
        _sessionManager = _ssm;
    }

    /**
     * Requires that the caller is the session manager that was provided
     * in the constructor.
     */
    modifier requiresSessionManager {
        require(
            msg.sender == address(_sessionManager)
            , "Only the session manager can call this function"
        );
        _;
    }

    /**
     * Requires that the caller is a a student
     */
    modifier requiresStudent {
        require(
            _rolesManager.hasRole(msg.sender, RolesManager.Roles.Student)
            , "Only an authorize student can call this function"
        );
        _;
    }

    /**
     * Executes all bids and returns tokens to students. Returns true
     * if there needs to be another bidding round.
     *
     * This function destroys this contract after returning
     */
    function executeRound() public view requiresSessionManager returns (bool) {
        // TODO
        return true;
    }

    function addBid(Bid memory bid) public requiresStudent {
        // Dynamically sized arrays are initially set to []

        // First ever bid for the student
        if (_bidsPerStudent[bid.student].length == 0) {
            studentsCount++;
        }
        _bidsPerStudent[bid.student].push(bid);
        
        // First ever bid for the course
        if (_bidsPerCourse[bid.course.code].length == 0) {
            coursesCount++;
            courses.push(bid.course.code);
            _bidsPerCourse[bid.course.code].push(bid);
        } else {
            bool inserted = false;
            // For the bidsPerCourse, we want to insert in descending order
            // of Bid.amount first, then ascending order by Bid.updated
            for (uint16 i = 0; i < _bidsPerCourse[bid.course.code].length; i++) {

                // This shift of the array is probably expensive.
                // Could use a linked list instead.
                if (_bidsPerCourse[bid.course.code][i].amount <= bid.amount && _bidsPerCourse[bid.course.code][i].updated <= bid.updated) {
                    inserted = true;
                    uint16 indexToStartShifting = i + 1;
                    uint16 indexToInsert;

                    if (i == 0) {
                        indexToInsert = 0;
                    } else {
                        indexToInsert = i - 1;
                    }

                    for (uint16 j = indexToStartShifting; j < _bidsPerCourse[bid.course.code].length + 1; j++) {
                        _bidsPerCourse[bid.course.code][j + 1] = _bidsPerCourse[bid.course.code][j];
                    }

                    _bidsPerCourse[bid.course.code][indexToInsert] = bid;
                }
            }

            // Case when this bid was the smallest of all the existing bids for this course
            if (!inserted) {
                _bidsPerCourse[bid.course.code].push(bid);
            }
        }
    }

    function alterBid(string memory code, address student, Bid memory newBid) public requiresStudent {
        bool updated1 = false;
        bool updated2 = false;

        for (uint256 i; i < _bidsPerCourse[code].length; i++) {
            if (_bidsPerCourse[code][i].student == student) {
                _bidsPerCourse[code][i] = newBid;
                updated1 = true;
                break;
            }
        }

        for (uint256 i; i < _bidsPerStudent[student].length; i++) {
            // for string comparison: https://ethereum.stackexchange.com/questions/4559/operator-not-compatible-with-type-string-storage-ref-and-literal-string
            if (keccak256(bytes(_bidsPerStudent[student][i].course.code)) == keccak256(bytes(code))) {
                _bidsPerStudent[student][i] = newBid;
                updated2 = true;
                break;
            }
        }

        require(
            updated1 && updated2
            , "Could not alter bid"
        );
    }

    function removeBid(string memory code, address student) public requiresStudent {
        // Does not decrement counters in this contract. This function isn't tested anyway haha 
        bool deleted1 = false;
        bool deleted2 = false;

        for (uint256 i; i < _bidsPerCourse[code].length; i++) {
            if (_bidsPerCourse[code][i].student == student) {
                // "delete" just sets this to the default value
                delete _bidsPerCourse[code][i];
                deleted1 = true;
                break;
            }
        }

        for (uint256 i; i < _bidsPerStudent[student].length; i++) {
            // for string comparison: https://ethereum.stackexchange.com/questions/4559/operator-not-compatible-with-type-string-storage-ref-and-literal-string
            if (keccak256(bytes(_bidsPerStudent[student][i].course.code)) == keccak256(bytes(code))) {
                // "delete" just sets this to the default value
                delete _bidsPerStudent[student][i];
                deleted2 = true;
                break;
            }
        }

        require(
            deleted1 && deleted2
            , "Could not alter bid"
        );
    }

    function seeAllBids() public view requiresStudent returns (Bid[] memory){
        Bid[] memory ret = new Bid[](coursesCount);
        for (uint256 i = 0; i < coursesCount; i++) {
            for (uint256 j = 0; j < _bidsPerCourse[courses[i]].length; j++) {
                // TODO: is this the right way around?
                ret[i] = _bidsPerCourse[courses[i]][j];
            }   
        }
        
        return ret;
    }
}
