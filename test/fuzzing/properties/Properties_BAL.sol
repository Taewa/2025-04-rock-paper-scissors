// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./PropertiesBase.sol";

abstract contract Properties_BAL is PropertiesBase {

  // BAL-01: A newly created game must have at least minimum bet ether
  function invariant_BAL_01(address playerA, uint256 bet) internal {
    if (playerA != address(0)) {
      fl.gte(bet, MIN_BET, BAL_01);
    }
  }
  
  // BAL-02: When a player joins a game, joiner has to put the same amount of ether as a bet
  // TODO: it's strange that adding "view" make Echidna behaves a bit werid. Having this kind of "*wait* Time delay: 1795724 seconds Block delay: 69939" message which doesn't hapeen when "view" is removed.
  function invariant_BAL_02(address playerA, address playerB, uint256 bet) internal {
    if (playerA != address(0) && playerB != address(0)) {
      assert(bet >= MIN_BET);

      // current ether balance - ether balance before playerB joining
      uint256 betFromPlayerB = states[1].etherBalance - states[0].etherBalance; 
      
      fl.eq(betFromPlayerB, bet, BAL_02);
    }
  }

  // BAL-03: Fund of contract should decrease after a game is finished
  // TODO: it doesn't check the decrease of fund of contract yet. Implement it.
  function invariant_BAL_03(uint256 accumulatedFeesBefore, uint256 accumulatedFeesAfter, uint256 totalPot) internal {
    uint256 expectedFee = (totalPot * 10) / 100; // 10% === PROTOCOL_FEE_PERCENT constant
    uint256 actualFee = accumulatedFeesAfter - accumulatedFeesBefore;
    
    fl.eq(actualFee, expectedFee, BAL_03);
  }

  // BAL-06: Fund of contract cannot be increased anymore by a game when two players are ready to play
  function invariant_BAL_06(bool isGameFull) internal {
    if (!isGameFull) return;

    uint256 betFromPlayerB = states[1].etherBalance - states[0].etherBalance; 

    if (betFromPlayerB > 0) {
      // This means a new player is allowed to join the game while the game is full. 
      // The previous joiner would lose their bet since it's out of control of the contract.
      fl.t(false, BAL_06);
    }
  }

  // BAL-07: The sum of bets of games should be equal to the fund of contract
  function invariant_BAL_07(uint256 totalGamesBet, uint256 totalContractBalance) internal {
    fl.eq(totalGamesBet, totalContractBalance, BAL_07);
  }

  function invariant_BAL_08(uint256 totalContractBalanceBefore, uint256 totalContractBalanceAfter) internal {
    fl.eq(totalContractBalanceBefore, totalContractBalanceAfter, BAL_08);
  }
}