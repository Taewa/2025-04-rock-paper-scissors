// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@perimetersec/fuzzlib/src/FuzzBase.sol";
import "@perimetersec/fuzzlib/src/IHevm.sol";
import "./FuzzStorageVariables.sol";

contract FuzzSetUp is FuzzBase, FuzzStorageVariables {
  constructor() payable {}

  function setup() internal {
    setRockPaperScissors();
    setPlayers();
  }

  function setRockPaperScissors() private {
    RPS = new RockPaperScissors();
  }

  function setPlayers() private {
    // Set each players ether
    PLAYER_A.call{value: 100 ether}("");
    PLAYER_B.call{value: 100 ether}("");
  }
}