// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract Counter {
    uint256 public count; //create a public variable to track our count

    // initialize a defualt count number
   constructor(uint256 initialCount) {
        count = initialCount;
    }

    //increase the current count by 1
    function increase() external {
        count++;
    }

    //decreases the current count by 1
    function decrease() external {
        count--;
    }
}
