// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./RolesManager.sol";
import "./RoundManager.sol";
import "../Factories/ManagerFactory.sol";
import "../Users/ChiefOperatingOfficer.sol";

/**
 * The TokensManager is responsible for managing student payments and allocating them tokens
 * to bid on course enrolments. The TokensManager implements inherits from the ERC20 contract
 */
contract TokensManager is ERC20 {

    address _COO;
    address internal _manager;

    constructor(uint256 initialSupply, address manager, address coo) ERC20("AdmissionTokens", "AT") {
        // The COO owns all the tokens
        _mint(coo, initialSupply);

        _manager = manager;
        _COO = coo;
    }

    modifier requiresCOO {
        require (
            msg.sender == _COO,
            "Only the Chief Operating Officer can call this function."
        );
        _;
    }

    modifier requiresRoundManager {
        require (
            msg.sender == address(ManagerFactory(_manager).getRoundManager()),
            "Only RoundManager can call this function."
        );
        _;
    }

    modifier requiresStudent {
        require (
            ManagerFactory(_manager).getRolesManager().hasRole(msg.sender, RolesManager.Roles.Student)
            , "Only a student can call this function."
        );
        _;
    }

    /**
     * Override for approve method. Restrict to this only.
     */
    function approve(address spender, uint256 amount) public override requiresCOO returns (bool) {
        return super.approve(spender, amount);
    }

    /**
     * Transfers token allowance from the sender to the recipient.
     * The university takes a 10% cut.
     *
     * Will fail and revert state if either transfer fails.
     */
    function transferToStudent(address recipient, uint256 amount) public requiresStudent returns (bool) {
        require(
            ManagerFactory(_manager).getRolesManager().hasRole(recipient, RolesManager.Roles.Student)
            , "Recipient must be a student"
        );

        address sender = msg.sender;

        uint256 universityFee = (amount * 1) / 10;
        uint256 newAmount = amount - universityFee;

        require(
            super.transferFrom(sender, address(this), universityFee)
            , "Could not transfer fee to university"
        );

        require(
            super.transferFrom(sender, recipient, newAmount)
            , "Could not transfer fee to student"
        );


        return true;
    }

    /**
     * Removes tokens from the total supply.
     */
    function destroyTokens(uint256 amount) public requiresRoundManager {
        return super._burn(_COO, amount);
    }
}
