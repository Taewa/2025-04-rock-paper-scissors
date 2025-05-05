// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import './FuzzRockPaperScissors.sol';

contract Fuzz is FuzzRockPaperScissors {
  constructor() payable {
    setup();
  }
}