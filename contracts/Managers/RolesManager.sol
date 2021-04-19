// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../Users/ChiefOperatingOfficer.sol";
import "../Users/Administrator.sol";
import "../Users/Student.sol";
import "../Factories/UserFactory.sol";

/**
 * The RolesManager is responsible for handling the permissions associated 
 * with each role. The RolesManager keeps track of which contracts have what role.
 */
contract RolesManager {
    
    enum Roles {Unknown, Admin, Student, Revoked}

    address internal _COO;
    address internal _userFactory;
    
    // Initially all values in mapping are set to "Unknown"
    mapping (address => Roles) internal _roles;

    constructor(address _coo, address userFactory) {
       _COO = _coo;
       _userFactory = userFactory;
    }

    /**
     * Requires that the caller is a system user
     */
    modifier requiresUser {
        require(
            (_roles[msg.sender] != Roles.Unknown 
            || _roles[msg.sender] != Roles.Revoked
            || msg.sender == address(_COO))
            , "Only a system user can call this function"
        );
        _;
    }

    /**
     * Requires that the caller is a a student
     */
    modifier requiresStudent {
        require(
            _roles[msg.sender] == Roles.Student
            , "Only an authorize student can call this function"
        );
        _;
    }

    /**
     * Authorizes the contract address to the supplied role
     */
    function authorize(address authorizee, Roles role) public requiresUser returns (address) {
        if (authorizee == address(_COO)) {
            require (
                false
                , "The Chief Operating Officer's permissions cannot be updated."
            );
        }

        if (role == Roles.Admin) {
            require (
                msg.sender == address(_COO)
                , "Only the Chief Operating Officer can authorize an administrator."
            );
        }

        if (role == Roles.Student) {
            require (
                _roles[msg.sender] == Roles.Admin
                , "Only an Administrator can authorize a student."
            );
        }

        if (role == Roles.Revoked) {
            // If the address being revoked is an admin, caller must be the COO
            require (
                msg.sender == address(_COO)
                , "Only the Chief Operating Officer can revoke permissions of an administrator."
            );

            // If the address being revoked is a student, caller must be an admin
            if (_roles[authorizee] == Roles.Student) {
                require (
                    _roles[msg.sender] == Roles.Admin
                    , "Only an Administrator can revoke permissions of a student."
                );
            }
        }

        // passed all checks, now we can authorize
        _roles[authorizee] = role;
        if (role == Roles.Admin) {
            return UserFactory(_userFactory).createAdmin(authorizee);            
        } else {
            return UserFactory(_userFactory).createStudent(authorizee);
        }       
    }

    /**
     * Returns true if the user has the supplied role
     */
    function hasRole(address user, Roles role) public view returns (bool) {
        return _roles[user] == role;
    }
}
