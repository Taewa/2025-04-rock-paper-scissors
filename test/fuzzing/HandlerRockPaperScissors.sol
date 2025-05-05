// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@perimetersec/fuzzlib/src/FuzzBase.sol";
import "./BeforeAfter.sol";
import "./PostCondition.sol";

contract HandlerRockPaperScissors is BeforeAfter, PostCondition {
  // Step 1: Create a game as player A
  function createGame(uint256 _totalTurns, uint256 _timeoutInterval, uint256 _betRaw) public {
    setTurnsAndTimeout(_totalTurns, _timeoutInterval);
    uint256 betEther = setBetAmount(_betRaw);

    // Check if PLAYER_A has enough ether
    assert(address(PLAYER_A).balance >= betEther);

    bytes memory createGameWithEthCalldata = abi.encodeWithSelector(RockPaperScissors.createGameWithEth.selector, _totalTurns, gameState.timeoutInterval);
    
    // Create game by playerA
    vm.prank(PLAYER_A);
    (bool success, bytes memory returnData) = address(RPS).call{value: betEther}(createGameWithEthCalldata);
    
    if (success) {
      gameState.gameId = abi.decode(returnData, (uint256)); // store for global use
    }

    createGamePostcondition(success, returnData, betEther);
  }

  // Step 2: Join game as player B
  function joinGame() public {
    // to capture the ether balance before joining
    _before(PLAYER_B); 
    
    // check if the game is already full. It shouldn't be allowed to join if the game is full.
    bool isFull = isGameFull(gameState.gameId);

    // calldata
    bytes memory joinGameWithEthCalldata = abi.encodeWithSelector(RockPaperScissors.joinGameWithEth.selector, gameState.gameId);
    
    vm.prank(PLAYER_B);
    (bool success, bytes memory returnData) = address(RPS).call{gas: 1000000, value: gameState.betEther}(joinGameWithEthCalldata);
    
    joinGamePostcondition(success, returnData, gameState.betEther);
  }

  // Step 3: Commit move
  // Rnadomly choose players to commit move
  function commitMove() public {
    // Randomly choose players to commit move
    if (block.timestamp % 2 == 0) {
      playerCommit(PLAYER_A);
    } else {
      playerCommit(PLAYER_B);
    }
  }

  // Unified commit function for both players
  function playerCommit(address player) public {
    _before(address(this));

    // Set salt and commitment based on player
    if (player == PLAYER_A) {
      gameState.saltA = keccak256(abi.encodePacked("salt for player A"));
      // randomly select a move (Rock, Paper, Scissors)
      gameState.commitA = keccak256(abi.encodePacked(uint8(randomMove(block.timestamp)), gameState.saltA));
    } else {
      gameState.saltB = keccak256(abi.encodePacked("salt for player B"));
      // randomly select a move (Rock, Paper, Scissors)
      gameState.commitB = keccak256(abi.encodePacked(uint8(randomMove(block.timestamp)), gameState.saltB));
    }
    
    // Perform the commitment
    vm.prank(player);
    bytes32 commitHash = (player == PLAYER_A) ? gameState.commitA : gameState.commitB;
    bytes memory data = abi.encodeWithSelector(RockPaperScissors.commitMove.selector, gameState.gameId, commitHash);
    (bool success, bytes memory returnData) = address(RPS).call{gas: 1000000}(data);
    
    playerCommitPostcondition(success, returnData);
  }

  // Step 5: Reveal move randomly by either player
  function revealMove() public {
    // Randomly choose which player reveals
    bool isCallSuccess;
    bytes memory callReturnData;

    if (block.timestamp % 2 == 0) {
      // Player A reveals
      vm.prank(PLAYER_A);
      uint8 moveA = uint8(randomMove(block.timestamp));
      bytes memory revealMoveCalldata = abi.encodeWithSelector(RockPaperScissors.revealMove.selector, gameState.gameId, moveA, gameState.saltA);
      (bool success, bytes memory returnData) = address(RPS).call{gas: 1000000}(revealMoveCalldata);
      
      isCallSuccess = success;
      callReturnData = returnData;
    } else {
      // Player B reveals (this reveal makes the game finished)
      vm.prank(PLAYER_B);
      uint8 moveB = uint8(randomMove(block.timestamp));
      bytes memory revealMoveCalldata = abi.encodeWithSelector(RockPaperScissors.revealMove.selector, gameState.gameId, moveB, gameState.saltB);
      (bool success, bytes memory returnData) = address(RPS).call{gas: 1000000}(revealMoveCalldata);
      
      isCallSuccess = success;
      callReturnData = returnData;
      // Record fees after game is finished (only when PLAYER_B reveals)
      _after(address(this));
    }

    revealMovePostcondition(isCallSuccess, callReturnData);
  }

  // TODO: this no longer works since commitMove randomly chooses players to commit move
  // Combined function for reference
  // function handleGameFeeCheck(uint256 _totalTurns, uint256 _timeoutInterval, uint256 _betRaw) internal {
  //   // Call each step in sequence
  //   createGame(_totalTurns, _timeoutInterval, _betRaw);
  //   joinGame();
  //   commitMove();
  //   revealMove();
  // }
}