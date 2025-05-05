// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

abstract contract PropertiesDescriptions {
  string internal constant BAL_01 = "BAL-01: A newly created game must have at least minimum bet ether";
  string internal constant BAL_02 = "BAL-02: When a player joins a game, joiner has to put the same amount of ether as a bet";
  // string internal constant BAL_03 = "BAL-03: Admin should get 10% of the total pot"; // TODO: replace with BAL-04
  string internal constant BAL_03 = "BAL-03: Fund of contract should decrease after a game is finished";  // TODO: to improve
  string internal constant BAL_04 = "BAL-04: [ETH mode] Accumulated fees should increase after a game"; // TODO: to implement
  string internal constant BAL_05 = "BAL-05: Fund of winner should increase after a game is finished";  // TODO: to implement
  string internal constant BAL_06 = "BAL-06: Fund of contract cannot be increased anymore by a game when two players are ready to play";
  string internal constant BAL_07 = "BAL-07: The sum of bets of games should be equal to the fund of contract";
  string internal constant BAL_08 = "BAL-08: The fund of contract should not be changed before a game is finished";
  
  string internal constant GAME_01 = "GAME-01: Current turn should not exceed total turns";
  string internal constant GAME_02 = "GAME-02: When the game is finished, the moves should be revealed";
  
  string internal constant TIME_01 = "TIME-01: commitMove must not revert";
  string internal constant TIME_02 = "TIME-02: Game timeout interval must never be successful";

}
