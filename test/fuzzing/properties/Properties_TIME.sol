// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./PropertiesBase.sol";

abstract contract Properties_TIME is PropertiesBase {
 
  // TIME-01: commitMove must not revert
  // No need this test actually since it's tested revealMovePostcondition() else case.
  function invariant_TIME_01(uint256 _timeoutInterval) internal {
    // It should not exceed max value of uint256
    fl.lte(_timeoutInterval, type(uint256).max - block.timestamp, TIME_01);
  }
}