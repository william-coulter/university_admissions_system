// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./RolesManager.sol";

/**
 *
 */
contract TokensManager is ERC20 {

    address internal _roundManager;
    RolesManager internal _rolesManager;

    constructor(uint256 initialSupply, address _rnd, RolesManager _rls) ERC20("AdmissionTokens", "AT") {
        _mint(msg.sender, initialSupply);
        _roundManager = _rnd;
        _rolesManager = _rls;
    }

    modifier requiresRoundManager {
        require (msg.sender == _roundManager, "Only RoundManager can call this function.");
        _;
    }

    modifier requiresStudent {
        require (
            _rolesManager.hasRole(msg.sender, RolesManager.Roles.Student)
            , "Only a student can call this function."
        );
        _;
    }

    /**
     * Approve a student to send tokens. TODO: Must receive Wei
     */
    function approve(address spender, uint256 amount) public virtual override requiresStudent returns (bool) {
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
            _rolesManager.hasRole(recipient, RolesManager.Roles.Student)
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
        return super._burn(address(this), amount);
    }
}
