// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

//import './IERC20Mint.sol';
//import '@openzeppelin/contracts/utils/Address.sol';
import '@openzeppelin/contracts/access/Ownable.sol';

interface INFT {
    struct Collection {
        bool exists;
        string name;
        uint factoryTime; // 50400 = 1 day
        uint tokenProductEmission;
        uint tokenUpgradePrice;
        uint tokenFactoryPrice;
        Property[] properties;
        uint nftCount;
        uint createdTime;
    }
    
    struct Property {
        string name;
        uint basicCount;
        uint createdTime;
    }
}