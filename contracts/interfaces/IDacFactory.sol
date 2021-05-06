// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

import {IDac} from "./IDac.sol";

interface IDacFactory {
    function getDacs() external view returns (IDac[] memory);
}
