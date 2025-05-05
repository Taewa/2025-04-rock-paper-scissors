// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./properties/Properties.sol";
import "./helper/RpsFuzzingHelper.sol";
contract PostCondition is Properties, RpsFuzzingHelper {

  function createGamePostcondition(bool success, bytes memory returnData, uint256 betEther) internal {
    if (success) {
      invariant_BAL_01(PLAYER_A, betEther);

      (uint256 totalGamesBet, uint256 totalBalance) = calculateTotalGamesBet();
      
      // TODO: uncomment this after fixing the BAL_07 bug. (calling joinGameWithEth(sameGameId) twice should not be allowed)
      // invariant_BAL_07(totalGamesBet, totalBalance);

    } else {
      bytes[] memory allowedErrors = new bytes[](4);
      allowedErrors[0] = abi.encode("Bet amount too small");
      allowedErrors[1] = abi.encode("Must have at least one turn");
      allowedErrors[2] = abi.encode("Total turns must be odd");
      allowedErrors[3] = abi.encode("Timeout must be at least 5 minutes");
      
      allowRequire(returnData, allowedErrors);
    }
  }

  function joinGamePostcondition(bool success, bytes memory returnData, uint256 betEther) internal {
    if (success) {
      // TODO: currently this test always fails. Need to automate creating a game first. 
      _after(PLAYER_B);
      invariant_BAL_02(PLAYER_A, PLAYER_B, betEther);
      // BAL_06 always fails since there is a bug in the joinGameWithEth().
      // invariant_BAL_06(isFull); // basically check if someone joins more than once
    } else {
      bytes[] memory allowedErrors = new bytes[](4);
      allowedErrors[0] = abi.encode("Game not open to join");
      allowedErrors[1] = abi.encode("Cannot join your own game");
      allowedErrors[2] = abi.encode("Join deadline passed");
      allowedErrors[3] = abi.encode("Bet amount must match creator's bet");

      allowRequire(returnData, allowedErrors);
    }
  }

  function playerCommitPostcondition(bool success, bytes memory returnData) internal {
    if (success) {
      (uint256 totalGamesBet, uint256 totalBalance) = calculateTotalGamesBet();      
      // @audit: BUG-02 uncomment this after fixing the BAL_07 bug. (calling joinGameWithEth(sameGameId) twice should not be allowed)
      // invariant_BAL_07(totalGamesBet, totalBalance);
      
      // Check if current turn does not exceed total turns
      invariant_GAME_01(gameState.gameId);
    } else {
      bytes[] memory allowedErrors = new bytes[](6);
      allowedErrors[0] = abi.encode("Not a player in this game");
      allowedErrors[1] = abi.encode("Game not in commit phase");
      allowedErrors[2] = abi.encode("Waiting for player B to join");
      allowedErrors[3] = abi.encode("Already committed");
      allowedErrors[4] = abi.encode("Not in commit phase");
      allowedErrors[5] = abi.encode("Moves already committed for this turn");
      
      // TODO: this logic of commitMove() might be dead code. But it's not a critical issue. Check later.
      // require(game.state == GameState.Committed, "Not in commit phase");

      allowRequire(returnData, allowedErrors);
    }
  }

  function revealMovePostcondition(bool success, bytes memory returnData) internal {
    (,, uint256 bet,,,,,,,,,,,,, RockPaperScissors.GameState state) = RPS.games(gameState.gameId);
    // if (state != RockPaperScissors.GameState.Finished) return;

    uint256 totalPot = bet * 2;
    uint256 feesBefore = states[0].accumulatedFees;
    uint256 feesAfter = states[1].accumulatedFees;
  
    
    if (success) {
      if (state == RockPaperScissors.GameState.Finished) {
        // TODO: never reach here
        // Only if the game is finished, the balance of contract should decrease.
        invariant_BAL_03(feesBefore, feesAfter, totalPot);
        // Both players should have revealed their moves
        invariant_GAME_02(gameState.gameId);
      } else {
        invariant_BAL_08(feesBefore, feesAfter);
      }
    } else {
      bytes[] memory allowedErrors = new bytes[](6);
      allowedErrors[0] = abi.encode("Not a player in this game");
      allowedErrors[1] = abi.encode("Game not in reveal phase");
      allowedErrors[2] = abi.encode("Reveal phase timed out");
      allowedErrors[3] = abi.encode("Invalid move");
      allowedErrors[4] = abi.encode("Hash doesn't match commitment");
      allowedErrors[5] = abi.encode("Move already revealed");

      allowRequire(returnData, allowedErrors);
    }
  }
}