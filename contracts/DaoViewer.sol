// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

import {IDac} from "./interfaces/IDac.sol";
import {IDaf} from "./interfaces/IDaf.sol";
import {IDacFactory} from "./interfaces/IDacFactory.sol";
import {IDafFactory} from "./interfaces/IDafFactory.sol";

contract DaoViewer {
    receive() external payable {
        revert();
    }

    fallback() external payable {
        revert();
    }

    function myDaos(
        address _userAddress,
        address _dacFactoryAddress,
        address _dafFactoryAddress
    ) external view returns (IDac[] memory, IDaf[] memory) {
        IDacFactory dacFactory = IDacFactory(_dacFactoryAddress);

        IDac[] memory dacs = dacFactory.getDacs();

        IDafFactory dafFactory = IDafFactory(_dafFactoryAddress);

        IDaf[] memory dafs = dafFactory.getDafs();

        IDac[] memory myDacs = new IDac[](dacs.length);

        IDaf[] memory myDafs = new IDaf[](dafs.length);

        for (uint256 i = 0; i < dacs.length; i++) {
            address[] memory teammates = dacs[i].getAllTeammates();

            for (uint256 j = 0; j < teammates.length; j++) {
                if (teammates[j] == _userAddress) {
                    myDacs[i] = dacs[i];
                    break;
                }
            }
        }

        for (uint256 i = 0; i < dafs.length; i++) {
            if (dafs[i].balanceOf(_userAddress) > 0) {
                myDafs[i] = dafs[i];
            }
        }

        return (myDacs, myDafs);
    }
}
