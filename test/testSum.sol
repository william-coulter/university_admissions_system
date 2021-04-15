// SPDX-License-Identifier: MIT

pragma solidity >=0.4.25 <0.9.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/Sum.sol";

contract TestSum {
  function testSumOfTwoNumbers() public {
    Sum sumContract = new Sum();

    uint num1 = 4;
    uint num2 = 6;

    uint expected = 10;

    Assert.equal(sumContract.getSum(num1, num2), expected, "Sum should be 10");
  }
}
