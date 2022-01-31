// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import './NFT.sol';
import './Marketplace.sol';

contract Factory is Ownable {
    using SafeERC20 for IERC20;
    NFT public nft;
    Marketplace public marketplace;
    address public burnAddress;
    address public devFeeAddress;
    uint8 public devFeePercent;
    IERC20 public breedCurrency;
    uint public breedPrice;

    constructor(address _nftAddress, address _marketplaceAddress, address _breedCurrencyAddress, uint _breedPrice, uint8 _devFeePercent) {
        nft = NFT(_nftAddress);
        marketplace = Marketplace(_marketplaceAddress);
        breedCurrency = IERC20(_breedCurrencyAddress);
        breedPrice = _breedPrice;
        devFeePercent = _devFeePercent;
        devFeeAddress = msg.sender;
    }

    function mint(address _recipient, uint _collectionID, string memory _name) public onlyOwner returns (uint) {
        return nft.mint(_recipient, _collectionID, _name);
    }

    function mintMore(address _recipient, _collectionID, string memory _name, uint _count) public onlyOwner {
        nft.mintMore(_recipient, _collectionID, _name, _count);
    }

    function mintToMarketplace(uint _count, string memory _name, uint _price) public onlyOwner {
        for (uint i = 0; i < _count; i++) {
            uint tokenID = mint(address(this), string(abi.encodePacked(_name, ' ', Strings.toString(i))));
            marketplace.deposit(address(nft), tokenID, _price);
        }
    }

    function breed(uint _nftMaleID, uint _nftFemaleID) public returns (uint){
        require(nft.ownerOf(_nftMaleID) == msg.sender, 'breed: First ID is not in your wallet');
        require(nft.ownerOf(_nftFemaleID) == msg.sender, 'breed: Second ID is not in your wallet');
        bool sexM;
        bool sexF;
        (,sexM,,,,,,,,) = getTokenDetails(_nftMaleID);
        (,sexF,,,,,,,,) = getTokenDetails(_nftFemaleID);
        require(sexM, 'breed: First ID is not male');
        require(!sexF, 'breed: Second ID is not female');
        breedCurrency.safeTransferFrom(msg.sender, address(this), breedPrice);
        breedCurrency.safeTransfer(devFeeAddress, breedPrice * devFeePercent / 100);
        breedCurrency.safeTransfer(burnAddress, breedPrice * (100 - devFeePercent) / 100);
        return nft.mint(msg.sender, 'Newborn');
    }

    function getTokenDetails(uint _id) private view returns (string memory, bool, uint, uint, uint, uint, uint, uint, uint, uint) {
        return nft.tokenDetails(_id);
    }

    function setDevFeeAddress(address _devFeeAddress) public onlyOwner {
        devFeeAddress = _devFeeAddress;
    }
}
