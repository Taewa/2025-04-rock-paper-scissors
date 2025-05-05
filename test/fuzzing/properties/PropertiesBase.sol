// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@perimetersec/fuzzlib/src/FuzzBase.sol";
import "./PropertiesDescriptions.sol";
import "../FuzzStorageVariables.sol";
import "../BeforeAfter.sol";

abstract contract PropertiesBase is FuzzBase, PropertiesDescriptions, FuzzStorageVariables, BeforeAfter {}
