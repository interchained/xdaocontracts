// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

import {IDaf} from "./IDaf.sol";

interface IDafFactory {
    function getDafs() external view returns (IDaf[] memory);
}
