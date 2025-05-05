// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

abstract contract FuzzIntegrityBase {
    function _testSelf(bytes memory callData) internal returns (bool, bytes4) {
        (bool success, bytes memory returnData) = address(this).delegatecall(callData);

        return (success, bytes4(returnData));
    }
}
