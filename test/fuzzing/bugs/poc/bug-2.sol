// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "src/RockPaperScissors.sol";
import "src/WinningToken.sol";
import "forge-std/Test.sol";

// [H-02] A user might join more than once in a game and lose ether forever
// The sum of bets of games should be equal to the fund of contract
contract Bug2Test is Test {
  RockPaperScissors public game;
  address public playerA;
  address public playerB;
  address public playerC;
  uint256 public gameId;

  function setUp() public {
    game = new RockPaperScissors();
    playerA = address(1);
    playerB = address(2);
    playerC = address(3);
  }

  function testBug2() public {
    // Step 1: Create game
    vm.deal(playerA, 1 ether);
    vm.startPrank(playerA);
    gameId = game.createGameWithEth{value: 0.01 ether}(
      1, // totalTurns
      300 // timeoutInterval
    );
    vm.stopPrank();

    // Step 2: First player joins
    vm.deal(playerB, 1 ether);
    vm.startPrank(playerB);
    game.joinGameWithEth{value: 0.01 ether}(gameId);  // note playerB puts 0.01 ether
    vm.stopPrank();

    // Step 3: Second player joins (this should be allowed but will cause issues)
    vm.deal(playerC, 1 ether);
    vm.startPrank(playerC);
    game.joinGameWithEth{value: 0.01 ether}(gameId);  // note playerC puts 0.01 ether and playerB's ether is lost control
    vm.stopPrank();

    // Step 4: Verify that the game has incorrect state
    // The game should have only 2 players, but due to the bug, it has 3
    // This will cause the first player (playerB) to lose their ether
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
    ) = game.games(gameId);
    
    assertEq(playerA, this.playerA());
    assertEq(joiner, playerC); // this means it was playerB but overwriten by playerC
    assertEq(bet, 0.01 ether);  // initial bet from creator

    // Step 5: Verify that contract's balance doesn't match game state
    // Contract should have 0.02 ether (creator + opponent bets)
    // But actually has 0.03 ether (creator + playerB + playerC bets)
    uint256 expectedBalance = bet * 2; // creator + opponent bets
    uint256 actualBalance = address(game).balance;
    assertEq(actualBalance, 0.03 ether); // creator + playerB + playerC bets
    assertGt(actualBalance, expectedBalance); // actual balance is greater than what it should be
    // Now playerB cannot take back their ether
  }
} 