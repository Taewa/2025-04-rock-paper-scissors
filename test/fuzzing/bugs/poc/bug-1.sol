// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "src/RockPaperScissors.sol";
import "src/WinningToken.sol";
import "forge-std/Test.sol";

// [H-01] Arithmetic overflow can happen in commit phase which can break the game
// Error: "[FAIL: panic: arithmetic underflow or overflow (0x11)]" message is shown in the console.
contract Bug1Test is Test {
    RockPaperScissors public game;
    address public playerA;
    address public playerB;
    uint256 public gameId;

    function setUp() public {
        game = new RockPaperScissors();
        playerA = address(1);
        playerB = address(2);
    }

    function testBug1() public {
        // Step 1: Create game with extremely large numbers that could cause overflow
        vm.deal(playerA, 1 ether);
        vm.startPrank(playerA);
        gameId = game.createGameWithEth{value: 0.01 ether}(
            3520814048892874906415526730303147317428128352495957196790214610038442751, // totalTurns
            115792089237316195423570985008687907853269984665640564039457584007913129639922 // timeoutInterval <- This is the problem
            // (115792089237316195423570985008687907853269984665640564039457584007913129639922 / 2) // try this as timeoutInterval. It will pass
        );
        vm.stopPrank();

        // Step 2: Join game
        vm.deal(playerB, 1 ether);
        vm.startPrank(playerB);
        game.joinGameWithEth{value: 0.01 ether}(gameId);
        vm.stopPrank();

        // Step 3: First commit move
        vm.startPrank(playerA);
        bytes32 commitHash = keccak256(abi.encodePacked(uint8(1), bytes32(0))); // Rock
        game.commitMove(gameId, commitHash);
        vm.stopPrank();

        // Step 4: Wait 305 seconds and try to commit again with playerB
        vm.warp(block.timestamp + 305);
        
        // This should fail due to arithmetic overflow
        vm.startPrank(playerB);
        commitHash = keccak256(abi.encodePacked(uint8(1), bytes32(0))); // Rock
        game.commitMove(gameId, commitHash);
        vm.stopPrank();
    }
} 