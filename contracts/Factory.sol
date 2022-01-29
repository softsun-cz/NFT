// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import '@openzeppelin/contracts/access/Ownable.sol';
import './NFT.sol';
import './Marketplace.sol';

contract Factory is Ownable {
    NFT public nft;
    Marketplace public marketplace;

    constructor(address _nftAddress, address _marketplaceAddress) {
        nft = NFT(_nftAddress);
        marketplace = Marketplace(_marketplaceAddress);
    }

    function mint(address _recipient, string memory _name) public onlyOwner {
        nft.mint(_recipient, _name);
    }

    function mintMore(address _recipient, uint _count, string memory _name) public onlyOwner {
        for (uint i = 0; i < _count; i++) mint(_recipient, string(abi.encodePacked(_name, ' ', Strings.toString(i))));
    }

    function mintToMarketplace(uint _count, string memory _name, uint _price) public onlyOwner {
        for (uint i = 0; i < _count; i++) {
            uint tokenID = mint(address(this), string(abi.encodePacked(_name, ' ', Strings.toString(i))));
            marketplace.deposit(address(nft), tokenID, _price);
        }
    }
}
