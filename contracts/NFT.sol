// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import './libs/ERC721MintMore.sol';
import './libs/IERC20Mint.sol';
import './libs/SafeERC20Mint.sol';
import './Marketplace.sol';
import '@openzeppelin/contracts/access/Ownable.sol';

contract NFT is ERC721MintMore, Ownable {
    using SafeERC20Mint for IERC20Mint;
    IERC20Mint public tokenProduct;
    IERC20Mint public tokenUpgrade;
    IERC20Mint public tokenFactory;
    Marketplace public marketplace;
    uint private rndCounter;
    uint public nftCount;
    string public nftName;
    string public nftSymbol;
    address public burnAddress;
    address public devFeeAddress;
    uint8 public devFeePercent;
    Collections[] collections;
    mapping (uint => NFTDetails) public nfts;
    event eventTransfer(address indexed _fromAddress, address indexed _toAddress, uint indexed _nftID);
    event eventNFTRename(uint indexed _nftID, string indexed _nameOld, string indexed _nameNew);
    event eventLevelUpgrade(uint indexed _nftID, uint indexed _levelOld, uint indexed _levelNew);
    event eventHarvestTokenProduct(uint indexed _nftID, address indexed _toAddress, uint indexed _amount);
    event eventFactory(uint indexed _nftMaleID, uint indexed _nftFemaleID, uint indexed _newID);
    event eventCollectionsAdd(uint indexed _collectionID, string indexed _name, uint indexed _tokenProductEmission);
    event eventCollectionsRename(uint indexed _collectionID, string indexed _nameOld, string indexed _nameNew);
    event eventCollectionSetTokenProductEmission(uint _collectionID, uint indexed _emissionOld, uint indexed _emissionNew);
    event eventCollectionSetTokenUpgradePrice(uint indexed _collectionID, uint indexed _priceOld, uint indexed _price);
    event eventCollectionSetTokenFactoryPrice(uint indexed _collectionID, uint indexed _priceOld, uint indexed _price);
    event eventCollectionsRemove(uint indexed _collectionID);
    event eventCollectionPropertiesAdd(uint indexed _collectionID, uint indexed _propertyID, string indexed _name);
    event eventCollectionPropertiesRename(uint indexed _collectionID, uint indexed _propertyID, string indexed _name);
    event eventCollectionPropertiesSetBasicCount(uint indexed _collectionID, uint _propertyID, uint _basicCount);
    event eventCollectionPropertiesRemove(uint indexed _collectionID, uint indexed _propertyID);
    event eventSetDevFeeAddress(address indexed devFeeAddressOld, address indexed _devFeeAddress);
    
    struct Collections {
        string name;
        Properties[] properties;
        uint tokenProductEmission;
        uint tokenUpgradePrice;
        uint tokenFactoryPrice;
        uint nftCount;
        uint createdTime;
    }

    struct Properties {
        string name;
        uint basicCount;
        uint createdTime;
    }

    struct NFTDetails {
        bool exists;
        bool sex;
        string name;
        uint collectionID;
        uint level;
        uint lastEmissionBlock;
        uint createdTime;
    }
    
    constructor(string memory _nftName, string memory _nftSymbol, uint8 _devFeePercent, address _devFeeAddress, address _burnAddress, address _marketplaceAddress, address _tokenFactoryAddress, address _tokenProductAddress, address _tokenUpgradeAddress) ERC721MintMore(_nftName, _nftSymbol) {
        nftName = _nftName;
        nftSymbol = _nftSymbol;
        devFeePercent = _devFeePercent;
        devFeeAddress = _devFeeAddress;
        burnAddress = _burnAddress;
        marketplace = Marketplace(_marketplaceAddress);
        tokenFactory = IERC20Mint(_tokenFactoryAddress);
        tokenProduct = IERC20Mint(_tokenProductAddress);
        tokenUpgrade = IERC20Mint(_tokenUpgradeAddress);
    }

    function transfer(address _toAddress, uint _nftID) public {
        require(ownerOf(_nftID) == msg.sender, 'transfer: You are not the owner of this NFT');
        harvestTokenProduct(_nftID);
        safeTransferFrom(msg.sender, address(this), _nftID);
        safeTransferFrom(address(this), _toAddress, _nftID);
        emit eventTransfer(msg.sender, _toAddress, _nftID);
    }

    function nftRename(uint _nftID, string memory _name) public {
        require(ownerOf(_nftID) == msg.sender, 'nftRename: You are not the owner of this NFT');
        require(getUTFStrLen(_name) <= 16, 'nftRename: Name is too long. Maximum: 16 characters');
        require(getCharMatch(_name), 'nftRename: Name can contain only a-z, A-Z, 0-9, space and dot');
        string memory nameOld = nfts[_nftID].name;
        nfts[_nftID].name = _name;
        emit eventNFTRename(_nftID, nameOld, _name);
    }

    function levelUpgrade(uint _nftID, uint _levels) public {
        require(ownerOf(_nftID) == msg.sender, 'levelUpgrade: You are not the owner of this NFT');
        uint amount = _levels * collections[nfts[_nftID].collectionID].tokenUpgradePrice;
        require(tokenUpgrade.allowance(msg.sender, address(this)) >= amount, 'levelUpgrade: Token Upgrade allowance is too low');
        tokenUpgrade.safeTransferFrom(msg.sender, address(this), amount);
        tokenUpgrade.safeTransfer(devFeeAddress, amount * devFeePercent / 10000);
        tokenUpgrade.safeTransfer(burnAddress, amount * (10000 - devFeePercent) / 10000);
        harvestTokenProduct(_nftID);
        uint levelOld = nfts[_nftID].level;
        nfts[_nftID].level += _levels;
        emit eventLevelUpgrade(_nftID, levelOld, nfts[_nftID].level);
    }

    function harvestTokenProduct(uint _nftID) public {
        require(ownerOf(_nftID) == msg.sender, 'harvestTokenProduct: You are not the owner of this NFT');
        uint toHarvest = getTokenProductToHarvest(_nftID);
        require(toHarvest != 0, 'harvestTokenProduct: No tokens to harvest');
        tokenProduct.mint(toHarvest);
        tokenProduct.safeTransfer(msg.sender, toHarvest);
        nfts[_nftID].lastEmissionBlock = block.number;
        emit eventHarvestTokenProduct(_nftID, msg.sender, toHarvest);
    }

    function getTokenProductToHarvest(uint _nftID) public view returns(uint) {
        return (block.number - nfts[_nftID].lastEmissionBlock) * nfts[_nftID].level * collections[nfts[_nftID].collectionID].tokenProductEmission / 10**tokenUpgrade.decimals();
    }

    function mint(address _recipient, uint _collectionID, string memory _name) public onlyOwner returns (uint) {
        require(_collectionID <= collections.length, 'mint: Wrong collection ID');
        require(getUTFStrLen(_name) <= 16, 'mint: Name is too long. Maximum: 16 characters');
        require(getCharMatch(_name), 'mint: Name can contain only a-z, A-Z, 0-9, space and dot');
        _safeMint(_recipient, nftCount);
        mintAddDetails(_collectionID, _name);
        return nftCount - 1;
    }

    function mintMore(address _recipient, uint _collectionID, string memory _name, uint _count) public onlyOwner returns (uint) {
        require(_collectionID <= collections.length, 'mintMore: Wrong collection ID');
        require(getUTFStrLen(_name) <= 16, 'mintMore: Name is too long. Maximum: 16 characters');
        require(getCharMatch(_name), 'mintMore: Name can contain only a-z, A-Z, 0-9, space and dot');
        _mintMore(_recipient, nftCount, _count);
        for (uint i = 0; i < _count; i++) mintAddDetails(_collectionID, string(abi.encodePacked(_name, ' ', Strings.toString(i))));
        return nftCount - 1;
    }

    function mintMoreToMarketplace(uint _collectionID, string memory _name, uint _price, uint _count) public onlyOwner {
        uint startID = nftCount - 1;
        mintMore(address(this), _collectionID, _name, _count);
        for (uint i = 0; i < _count; i++) marketplace.deposit(address(this), startID + i, _price);
    }

    function mintAddDetails(uint _collectionID, string memory _name) private onlyOwner {
        nfts[nftCount] = NFTDetails(true, getRandomNumber(2) == 1 ? true : false, _name, _collectionID, 1, block.number, block.timestamp);
        collections[_collectionID].nftCount++;
        nftCount++;
    }

    function factory(uint _nftMaleID, uint _nftFemaleID, string memory _name) public {
        require(ownerOf(_nftMaleID) == msg.sender, 'factory: First ID is not in your wallet');
        require(ownerOf(_nftFemaleID) == msg.sender, 'factory: Second ID is not in your wallet');
        require(nfts[_nftMaleID].collectionID == nfts[_nftFemaleID].collectionID, 'factory: Male ID and female ID are not from the same collection.');
        require(nfts[_nftMaleID].sex, 'factory: First ID is not male');
        require(!nfts[_nftFemaleID].sex, 'factory: Second ID is not female');
        tokenFactory.safeTransferFrom(msg.sender, address(this), collections[nfts[_nftMaleID].collectionID].tokenFactoryPrice);
        tokenFactory.safeTransfer(devFeeAddress, collections[nfts[_nftMaleID].collectionID].tokenFactoryPrice * devFeePercent / 10000);
        tokenFactory.safeTransfer(burnAddress, collections[nfts[_nftMaleID].collectionID].tokenFactoryPrice * (10000 - devFeePercent) / 10000);
        uint newID = mint(msg.sender, nfts[_nftMaleID].collectionID, _name);
        emit eventFactory(_nftMaleID, _nftFemaleID, newID);
    }

    function collectionAdd(string memory _name, uint _tokenProductEmission, uint _tokenUpgradePrice, uint _tokenFactoryPrice) public onlyOwner {
        Properties[] memory propTemplate;
        //collections.push(Collections(_name, new Properties[](0), _tokenProductEmission, _tokenUpgradePrice, _tokenFactoryPrice, 0, block.timestamp));
        collections.push(Collections(_name, propTemplate, _tokenProductEmission, _tokenUpgradePrice, _tokenFactoryPrice, 0, block.timestamp));
        emit eventCollectionsAdd(collections.length, _name, _tokenProductEmission);
    }

    function collectionRename(uint _collectionID, string memory _name) public onlyOwner {
        require(_collectionID <= collections.length, 'collectionRename: Wrong collection ID');
        string memory nameOld = collections[_collectionID].name;
        collections[_collectionID].name = _name;
        emit eventCollectionsRename(_collectionID, nameOld, _name);
    }

    function collectionSetTokenProductEmission(uint _collectionID, uint _emission) public onlyOwner {
        require(collections[_collectionID].nftCount == 0, 'collectionSetTokenProductEmission: Cannot set token Product emission in collection that has NFTs.');
        uint emissionOld = collections[_collectionID].tokenProductEmission;
        collections[_collectionID].tokenProductEmission = _emission;
        emit eventCollectionSetTokenProductEmission(_collectionID, emissionOld, _emission);
    }

    function collectionSetTokenUpgradePrice(uint _collectionID, uint _price) public onlyOwner {
        require(collections[_collectionID].nftCount == 0, 'collectionSetTokenUpgradePrace: Cannot set token Upgrade price in collection that has NFTs.');
        uint priceOld = collections[_collectionID].tokenUpgradePrice;
        collections[_collectionID].tokenUpgradePrice = _price;
        emit eventCollectionSetTokenUpgradePrice(_collectionID, priceOld, _price);
    }

    function collectionSetTokenFactoryPrice(uint _collectionID, uint _price) public onlyOwner {
        require(collections[_collectionID].nftCount == 0, 'collectionSetTokenFactoryPrice: Cannot set token Upgrade price in collection that has NFTs.');
        uint priceOld = collections[_collectionID].tokenFactoryPrice;
        collections[_collectionID].tokenFactoryPrice = _price;
        emit eventCollectionSetTokenFactoryPrice(_collectionID, priceOld, _price);
    }

    function collectionRemove(uint _collectionID) public onlyOwner {
        require(_collectionID <= collections.length, 'collectionRemove: Wrong collection ID');
        require(collections[_collectionID].nftCount == 0, 'collectionRemove: Cannot remove collection that has NFTs.');
        delete collections[_collectionID];
        emit eventCollectionsRemove(_collectionID);
    }

    function collectionPropertyAdd(uint _collectionID, string memory _name, uint _basicCount) public onlyOwner {
        require(_collectionID <= collections.length, 'collectionPropertyAdd: Wrong collection ID');
        require(collections[_collectionID].nftCount == 0, 'collectionPropertyAdd: Cannot add property, because it was already used in collection that has NFTs.');
        collections[_collectionID].properties.push(Properties(_name, _basicCount, block.timestamp));
        emit eventCollectionPropertiesAdd(_collectionID, collections[_collectionID].properties.length, _name);
    }

    function collectionPropertyRename(uint _collectionID, uint _propertyID, string memory _name) public onlyOwner {
        require(_collectionID <= collections.length, 'collectionPropertyRename: Wrong collection ID');
        require(_propertyID <= collections[_collectionID].properties.length, 'collectionPropertyRename: Wrong property ID');
        collections[_propertyID].name = _name;
        emit eventCollectionPropertiesRename(_collectionID, _propertyID, _name);
    }

    function collectionPropertySetBasicCount(uint _collectionID, uint _propertyID, uint _basicCount) public onlyOwner {
        require(_collectionID <= collections.length, 'collectionPropertySetBasicCount: Wrong collection ID');
        require(_propertyID <= collections[_collectionID].properties.length, 'collectionPropertySetBasicCount: Wrong property ID');
        require(collections[_collectionID].nftCount == 0, 'collectionPropertySetBasicCount: Cannot remove property, because it was already used in collection that has NFTs.');
        collections[_collectionID].properties[_propertyID].basicCount = _basicCount;
        emit eventCollectionPropertiesSetBasicCount(_collectionID, _propertyID, _basicCount);
    }

    function collectionPropertyRemove(uint _collectionID, uint _propertyID) public onlyOwner {
        require(_collectionID <= collections.length, 'collectionPropertyRemove: Wrong collection ID');
        require(_propertyID <= collections[_collectionID].properties.length, 'collectionPropertyRemove: Wrong property ID');
        require(collections[_collectionID].nftCount == 0, 'collectionPropertyRemove: Cannot remove property, because it was already used in collection that has NFTs.');
        delete collections[_collectionID].properties[_propertyID];
        emit eventCollectionPropertiesRemove(_collectionID, _propertyID);
    }

    function getRandomNumber(uint _num) private returns (uint) {
        rndCounter = rndCounter >= 1000 ? 0 : rndCounter++;
        return uint(uint(keccak256(abi.encodePacked(block.timestamp, rndCounter))) % _num);
    }

    function getUTFStrLen(string memory str) pure internal returns (uint) {
        uint length = 0;
        uint i = 0;
        bytes memory string_rep = bytes(str);
        while (i < string_rep.length) {
            if (string_rep[i] >> 7 == 0) i++;
            else if (string_rep[i] >> 5 == bytes1(uint8(0x6))) i += 2;
            else if (string_rep[i] >> 4 == bytes1(uint8(0xE))) i += 3;
            else if (string_rep[i] >> 3 == bytes1(uint8(0x1E))) i += 4;
            else i++;
            length++;
        }
        return length;
    }
    
    function getCharMatch(string memory str) pure internal returns (bool) { // ASCII table: https://www.asciitable.com/
        bytes memory b = bytes(str);
        for (uint i; i < b.length; i++) {
            bytes1 char = b[i];
            if (!(char >= 0x61 && char <= 0x7A) && // a-z
                !(char >= 0x41 && char <= 0x5A) && // A-Z
                !(char >= 0x30 && char <= 0x39) && // 0-9
                !(char == 0x20) && // Space
                !(char == 0x2E) // Dot
            ) return false;
        }
        return true;
    }

    function setDevFeeAddress(address _devFeeAddress) public onlyOwner {
        address devFeeAddressOld = devFeeAddress;
        devFeeAddress = _devFeeAddress;
        emit eventSetDevFeeAddress(devFeeAddressOld, _devFeeAddress);
    }
}
