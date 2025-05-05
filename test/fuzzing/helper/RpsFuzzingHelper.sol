// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import '@perimetersec/fuzzlib/src/FuzzBase.sol';
import '../../../src/RockPaperScissors.sol';
import '../FuzzStorageVariables.sol';

contract RpsFuzzingHelper is FuzzBase, FuzzStorageVariables {
  /**
   * @notice Pick existing game id
   * @param randomId Random id
   * @return Existing game id
   */
  function pickExistingGameId(uint256 randomId) internal returns(uint256) {
    uint256 max = RPS.gameCounter() - 1;
    
    // Return existing game id
    return fl.clamp(randomId, 0, max);
  }
  
  function allowRequire(bytes memory failedData, bytes[] memory allowedErrorMessages) internal {
    bytes memory strippedData;
    bool allowed = false;

    // 4 bytes are removed from the beginning of the data (4 bytes are the selector of the function. in this case, it's Error(string))
    if (failedData.length > 4) {
      strippedData = new bytes(failedData.length - 4);
      for (uint i = 0; i < failedData.length - 4; i++) {
        strippedData[i] = failedData[i + 4];
      }
    } else if (failedData.length == 4) {
      strippedData = "";
    } else {
      strippedData = failedData;
    }

    for (uint256 i = 0; i < allowedErrorMessages.length; i++) {
      if (keccak256(strippedData) == keccak256(allowedErrorMessages[i])) {
        allowed = true;
        break;
      }
    }

    // string conversion attempt, if failed, replace with "unknown error"
    string memory errorMsg;
    if (strippedData.length == 0) {
      errorMsg = "unknown error";
    } else {
      // try-catch is only available for external calls, so defensively handle it
      // when converting bytes to string, invalid UTF-8 may cause panic
      // so convert it safely using assembly
      assembly {
        errorMsg := add(strippedData, 0x20)
      }
    }

    fl.t(allowed, errorMsg);
  }

  function isGameFull(uint256 gameId) internal view returns (bool) {
    // check if the game is already joined
    (
      address playerA,
      address playerB,
      uint256 bet,
      ,,,,,,,,,,,,
    ) = RPS.games(gameId);

    if (
      playerA != address(0) 
      && playerB != address(0) 
      && bet > 0
    ) {
      // That means the game is full!
      return true;
    }

    return false;
  }

  /**
   * @notice Generate a random move (Rock, Paper, or Scissors)
   */
  function randomMove(uint256 randomValue) internal pure returns (RockPaperScissors.Move) {
    // 0,1 or 2
    uint8 moveIndex = uint8(randomValue % 3);
    
    if (moveIndex == 0) {
      return RockPaperScissors.Move.Rock;
    } else if (moveIndex == 1) {
      return RockPaperScissors.Move.Paper;
    } else {
      return RockPaperScissors.Move.Scissors;
    }
  }

  function clampTimeoutInterval(uint256 _timeoutInterval) internal pure returns (uint256) {
    // prevent overflow of uint256
    uint256 maxTimeout = type(uint256).max / 2; // To avoid BUG-1
    if (_timeoutInterval > maxTimeout) {
        return maxTimeout;
    }
    return _timeoutInterval;
  }

  function setTurnsAndTimeout(uint256 _totalTurns, uint256 _timeoutInterval) internal returns (uint256, uint256) {
    // Set turns which is odd number
    gameState.totalTurns = (_totalTurns % 10) * 2 + 1; // Random odd number between 1 and 19
    gameState.timeoutInterval = clampTimeoutInterval(_timeoutInterval);

    return (gameState.totalTurns, gameState.timeoutInterval); // return for local use
  }
  
  function setBetAmount(uint256 _betRaw) internal returns (uint256) {
    // Set bet amount (0.01 ETH ~ 10 ETH)
    uint256 min = 0.01 ether;
    uint256 max = 1 ether;
    uint256 range = max - min;
    uint256 betEther = (_betRaw % range) + min;
    gameState.betEther = betEther; // store for global use

    return betEther;  // return for local use
  }

  function calculateTotalGamesBet() internal view returns (uint256, uint256) {
    uint256 totalGamesBet = 0;
    uint256 totalBalance = address(RPS).balance;

    for (uint256 i = 0; i < RPS.gameCounter(); i++) {
      (address joinedPlayerA, address joinedPlayerB, uint256 bet ,,,,,,,,,,,,, RockPaperScissors.GameState state) = RPS.games(i);
      bool hasBetInGame = (state == RockPaperScissors.GameState.Created || state == RockPaperScissors.GameState.Committed);
      bool hasTwoPlayersInGame = (joinedPlayerA != address(0) && joinedPlayerB != address(0));

      if (hasBetInGame) {
        uint256 gameBet = hasTwoPlayersInGame ? bet * 2 : bet;
        totalGamesBet += gameBet;
      }
    }

    return (totalGamesBet, totalBalance);
  }
}