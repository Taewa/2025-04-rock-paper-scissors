// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import '../../src/RockPaperScissors.sol';
import './FuzzConstant.sol';

abstract contract FuzzStorageVariables is FuzzConstants {
  ///////////////////////////////////////////////////////////////////////////////////////////////
  //                                      Structs                                        
  ///////////////////////////////////////////////////////////////////////////////////////////////
  struct GameState {
    uint256 gameId;
    uint256 betEther;
    uint256 totalTurns;
    uint256 timeoutInterval;
    bytes32 saltA;
    bytes32 saltB;
    bytes32 commitA;
    bytes32 commitB;
  }

  ///////////////////////////////////////////////////////////////////////////////////////////////
  //                                      Variables                                        
  ///////////////////////////////////////////////////////////////////////////////////////////////
  GameState internal gameState;

  // Target contract
  RockPaperScissors internal RPS;
}