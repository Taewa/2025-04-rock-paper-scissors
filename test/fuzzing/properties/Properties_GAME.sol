// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./PropertiesBase.sol";

abstract contract Properties_GAME is PropertiesBase {

  // GAME-01: Current turn should not exceed total turns
  function invariant_GAME_01(uint256 gameId) internal {
    (
      address creator, // creator
      address joiner, // opponent
      uint256 bet,
      uint256 timeoutInterval,
      uint256 revealDeadline,
      uint256 creationTime,
      uint256 joinDeadline,
      uint256 totalTurns,
      uint256 currentTurn,
      bytes32 commitA,
      bytes32 commitB,
      RockPaperScissors.Move moveA,
      RockPaperScissors.Move moveB,
      uint8 scoreA,
      uint8 scoreB,
      RockPaperScissors.GameState state
    ) = RPS.games(gameId);
    
    fl.lte(currentTurn, totalTurns, GAME_01);
  }

  function invariant_GAME_02(uint256 gameId) internal {
    (
      address creator, // creator
      address joiner, // opponent
      uint256 bet,
      uint256 timeoutInterval,
      uint256 revealDeadline,
      uint256 creationTime,
      uint256 joinDeadline,
      uint256 totalTurns,
      uint256 currentTurn,
      bytes32 commitA,
      bytes32 commitB,
      RockPaperScissors.Move moveA,
      RockPaperScissors.Move moveB,
      uint8 scoreA,
      uint8 scoreB,
      RockPaperScissors.GameState state
    ) = RPS.games(gameId);

    bool playerARevealed = moveA != RockPaperScissors.Move.None;
    bool playerBRevealed = moveB != RockPaperScissors.Move.None;

    if (state == RockPaperScissors.GameState.Finished) {
      fl.t((playerARevealed && playerBRevealed), GAME_02);
    }
  }
} 