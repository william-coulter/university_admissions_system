// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./RolesManager.sol";
import "./RoundManager.sol";
import "../Users/ChiefOperatingOfficer.sol";

/**
 * The TokensManager is responsible for managing student payments and allocating them tokens
 * to bid on course enrolments. The TokensManager implements inherits from the ERC20 contract
 */
contract TokensManager is ERC20 {

    uint256 internal constant _tokensPerUoC = 100;

    ChiefOperatingOfficer internal _COO;

    RoundManager internal _roundManager;
    RolesManager internal _rolesManager;

    constructor(uint256 initialSupply, ChiefOperatingOfficer _coo) ERC20("AdmissionTokens", "AT") {
        _mint(msg.sender, initialSupply);

        _COO = _coo;

        _roundManager = _COO.getRoundManager();
        _rolesManager = _COO.getRolesManager();
    }

    modifier requiresRoundManager {
        require (msg.sender == address(_roundManager), "Only RoundManager can call this function.");
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
     * Receives Wei and approves student to spend according to their desired UoC.
     */
    function purchaseUoC(address spender, uint8 UoC) public payable virtual requiresStudent returns (bool) {
        uint256 requiredWei = UoC * _COO.getFee();

        require(
            msg.value >= requiredWei
            , "TokensManager: Not enough Wei sent to purchase UoC"
        );

        require(
            msg.value == requiredWei
            , "TokensManager: Too much Wei sent to purchase UoC"
        );

        return super.approve(spender, _tokensPerUoC * UoC);
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
