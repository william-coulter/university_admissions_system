// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CourseManager {

    constructor() {}

    struct Course {
        string code;
        string name;
        uint16 quota;
        uint16 enrolled;
        uint8 UoC;
    }
}
