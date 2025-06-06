// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

abstract contract FuzzConstants {
  ///////////////////////////////////////////////////////////////////////////////////////////////
  //                                         Players                                      
  ///////////////////////////////////////////////////////////////////////////////////////////////
  address internal constant PLAYER_A = address(0x10001);  // in echidna-config.yaml, "sender" has some preset such as lots of ethers. To have brand new address, just add +1 (....)
  address internal constant PLAYER_B = address(0x20001);

  ///////////////////////////////////////////////////////////////////////////////////////////////
  //                                         Values                                      
  ///////////////////////////////////////////////////////////////////////////////////////////////
  uint256 internal constant MIN_BET = 0.01 ether;
}