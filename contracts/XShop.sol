// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

import {IERC20} from "./IERC20.sol";

interface IDAO {
    function currency() external view returns (address);
}

contract XShop {
    address public immutable daoAddress;

    address public immutable daoCurrency;

    address public constant WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;

    struct Offer {
        address recipient;
        uint256 governanceTokensAmount;
        uint256 currencyAmount;
        bool isActive;
        uint256 index;
    }

    Offer[] public offers;

    constructor(address _daoAddress) {
        daoAddress = _daoAddress;

        daoCurrency = IDAO(_daoAddress).currency();
    }

    function createOffer(
        address _recipient,
        uint256 _governanceTokensAmount,
        uint256 _currencyAmount
    ) external returns (bool success) {
        require(msg.sender == daoAddress);

        offers.push(
            Offer({
                recipient: _recipient,
                governanceTokensAmount: _governanceTokensAmount,
                currencyAmount: _currencyAmount,
                isActive: true,
                index: offers.length
            })
        );

        return true;
    }

    function deactivateOffer(uint256 _index) external returns (bool success) {
        require(msg.sender == daoAddress);

        offers[_index].isActive = false;

        return true;
    }

    function getGovernanceTokens(uint256 _index) external payable returns (bool success) {
        Offer storage offer = offers[_index];

        require(offer.isActive == true);

        offer.isActive = false;

        require(msg.sender == offer.recipient);

        if (daoCurrency == WBNB) {
            require(msg.value >= offer.currencyAmount);
        } else {
            bool b1 = IERC20(daoCurrency).transferFrom(msg.sender, daoAddress, offer.currencyAmount);

            require(b1);
        }

        bool b2 = IERC20(daoAddress).transferFrom(daoAddress, msg.sender, offer.governanceTokensAmount);

        require(b2);

        return true;
    }

    function releaseCoins() external returns (bool success) {
        require(msg.sender == daoAddress);

        payable(daoAddress).transfer(address(this).balance);

        return true;
    }

    function getOffers() external view returns (Offer[] memory) {
        return offers;
    }
}
