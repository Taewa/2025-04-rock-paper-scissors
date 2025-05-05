// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@perimetersec/fuzzlib/src/FuzzBase.sol";
import "./FuzzIntegrityBase.sol";
import "./HandlerRockPaperScissors.sol";
import '../../src/RockPaperScissors.sol';

contract FuzzRockPaperScissors is FuzzBase, HandlerRockPaperScissors, FuzzIntegrityBase {

}