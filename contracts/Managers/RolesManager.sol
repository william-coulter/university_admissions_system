// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * The RolesManager is responsible for handling the permissions associated 
 * with each role. The RolesManager keeps track of which contracts have what role.
 */
contract RolesManager {
    
    enum Roles {Unknown, Admin, Student, Revoked}

    mapping (address => Roles) internal _roles;
    address internal _COO;

    constructor(address _coo) {
       _COO = _coo;
    }

    /**
     * Requires that the caller is a system user
     */
    modifier requiresUser {
        require(
            (_roles[msg.sender] != Roles.Unknown || msg.sender == _COO)
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
        if (authorizee == _COO) {
            require (
                false
                , "The Chief Operating Officer's permissions cannot be updated."
            );
        }

        if (role == Roles.Admin) {
            require (
                msg.sender == _COO
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
                msg.sender == _COO
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

        return address(0);
        // TODO: create new contract and return address

    }

    /**
     * Returns true if the user has the supplied role
     */
    function hasRole(address user, Roles role) public view requiresUser returns (bool) {
        return _roles[user] == role;
    }
}
