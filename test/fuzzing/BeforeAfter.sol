// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./FuzzSetup.sol";

abstract contract BeforeAfter is FuzzSetUp {
  ///////////////////////////////////////////////////////////////////////////////////////////////
  //                                         STRUCTS                                           //
  ///////////////////////////////////////////////////////////////////////////////////////////////
  struct RPSState {
    // mapping(address => TokenState) tokenStates;
    address actor;
    uint256 etherBalance; // Total ether balance of the contract  
    uint256 tokenBalance; // Total token balance of the contract
    uint256 accumulatedFees; // Total accumulated fees of the contract (e.g.: all games fees)
  }

  ///////////////////////////////////////////////////////////////////////////////////////////////
  //                                         VARIABLES                                         //
  ///////////////////////////////////////////////////////////////////////////////////////////////

  // callNum => State (callNum: 0 => before, callNum: 1 => after)
  mapping(uint8 => RPSState) states;

  ///////////////////////////////////////////////////////////////////////////////////////////////
  //                                         FUNCTIONS                                         //
  ///////////////////////////////////////////////////////////////////////////////////////////////

  // function _before(address actor, uint256 etherBalance) internal {
  function _before(address actor) internal {
    _captureState(0, actor);
  }

  function _after(address actor) internal {
    _captureState(1, actor);
  }

  /**
   * @param callNum 0=before, 1=after
   */
  function _captureState(uint8 callNum, address actor) internal {
    states[callNum].actor = actor;
    states[callNum].etherBalance = address(RPS).balance;
    states[callNum].accumulatedFees = RPS.accumulatedFees();
    // TODO: maybe adding game data can be helpful
  }
}