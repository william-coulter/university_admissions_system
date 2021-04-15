// SPDX-License-Identifier: MIT

/**
 * A test contract to check development environment before writing actual contracts
 */ 
pragma solidity >=0.4.22 <0.9.0;

contract Sum {
  function getSum(uint num1, uint num2) public pure returns (uint) {
    return num1 + num2;
  }
}
