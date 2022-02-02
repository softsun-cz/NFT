// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IMarketplace {
    function deposit(address _addressContract, uint _tokenID, uint _price) external;
    function withdraw(uint _id) external;
    function buy(uint _id) external;
    function changePrice(uint _id, uint _priceNew) external;
    function addAcceptedContract(address _addressContract) external;
    function setDevFeeAddress(address _devFeeAddress) external;
    event eventDeposit(uint indexed _depositID, Deposit indexed _deposit);
    event eventWithdraw(uint indexed _withdrawID, Withdraw indexed _withdraw);
    event eventBuy(uint indexed _buyID, Buy indexed _buy);
    event eventChangePrice(uint indexed _changePriceID, ChangePrice indexed _changePrice);
    
    struct Deposit {
        address _addressContract;
        uint _tokenID;
        address _owner;
        uint _price;
        uint _timestamp;
    }

    struct Withdraw {
        address _addressContract;
        uint _tokenID;
        address _owner;
        uint _price;
        uint _timestamp;
    }

    struct Buy {
        address _addressContract;
        uint _tokenID;
        address _ownerPrevious;
        address _ownerNew;
        uint _price;
        uint _timestamp;
    }

    struct ChangePrice {
        address _addressContract;
        uint _tokenID;
        address _owner;
        uint _priceOld;
        uint _priceNew;
        uint _timestamp;
    }

    struct Details {
        address addressContract;
        uint tokenID;
        address owner;
        uint price;
    }
}
