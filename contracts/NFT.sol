// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import './libs/ERC721MintMore.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/access/Ownable.sol';

contract NFT is ERC721MintMore, Ownable {
    IERC20 public tokenProduct;
    IERC20 public tokenUpgrade;
    uint private rndCounter;
    uint public nftCount;
    string public nftName;
    string public nftSymbol;
    Collections[] collections;
    Properties[] properties;
    mapping (uint => NFTDetails) public nftDetails;
    event eventNFTRename(uint indexed _nftID, string indexed _nameOld, string indexed _nameNew);
    event eventCollectionsAdd(uint indexed _collectionID, string indexed _name, uint indexed _productTokenEmission);
    event eventCollectionsRename(uint indexed _collectionID, string indexed _nameOld, string indexed _nameNew);
    event eventCollectionChangeEmission(uint _collectionID, uint indexed _emissionOld, uint indexed _emission);
    event eventCollectionsRemove(uint indexed _collectionID);
    event eventPropertiesAdd(uint indexed _propertyID, string indexed _name, uint indexed _basicCount);
    event eventPropertiesRename(uint indexed _propertyID, string indexed _nameOld, string indexed _nameNew);
    event eventPropertiesChangeBasicCount(uint _propertyID, uint _basicCountOld, uint _basicCount);
    event eventPropertiesRemove(uint indexed _propertyID); 

    struct Collections {
        bool exists;
        string name;
        uint tokenProductEmission;
        uint nftCount;
        uint createdTime;
    }

    struct Properties {
        uint collectionID;
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
        uint emissionUpdateTime; // TODO: updatovat pri harvestu a pri zmene levelu - pri zmene levelu se udela harvest
        uint createdTime;
    }
    // TODO: pridat kod pro upgrade tokenu
    constructor(string memory _nftName, string memory _nftSymbol, address _tokenProductAddress, address _tokenUpgradeAddress) ERC721MintMore(_nftName, _nftSymbol) {
        nftName = _nftName;
        nftSymbol = _nftSymbol;
        tokenProduct = IERC20(_tokenProductAddress);
        tokenUpgrade = IERC20(_tokenUpgradeAddress);
    }

    function nftRename(uint _nftID, string memory _name) public {
        require(ownerOf(_nftID) == msg.sender, 'setNFTName: You are not the owner of this NFT');
        require(getUTFStrLen(_name) <= 16, 'setNFTName: Name is too long. Maximum: 16 characters');
        require(getCharMatch(_name), 'setNFTName: Name can contain only a-z, A-Z, 0-9, space and dot');
        string memory nameOld = nftDetails[_nftID].name;
        nftDetails[_nftID].name = _name;
        emit eventNFTRename(_nftID, nameOld, _name);
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

    function mintAddDetails(uint _collectionID, string memory _name) private onlyOwner {
        // TODO: check if all properties are set!
        // body, eyes, nose, mouth, ears, tail
        // getPropertiesByCollection ?
        nftDetails[nftCount] = NFTDetails(true, getRandomNumber(2) == 1 ? true : false, _name, _collectionID, 1, block.timestamp);
        nftCount++;
    }

    function collectionAdd(string memory _name, uint _productTokenEmission) public onlyOwner {
        collections.push(Collections(true, _name, _productTokenEmission, block.timestamp));
        emit eventCollectionsAdd(collections.length, _name, _productTokenEmission);
    }

    function collectionRename(uint _collectionID, string memory _name) public onlyOwner {
        require(_collectionID <= collections.length, 'collectionRename: Wrong collection ID');
        string memory nameOld = collections[_collectionID].name;
        collections[_collectionID].name = _name;
        emit eventCollectionsRename(_collectionID, nameOld, _name);
    }

    function collectionChangeEmission(uint _collectionID, uint _emission) public onlyOwner {
        require(collections[_collectionID].nftCount == 0, 'collectionRemove: Cannot remove collection that has NFTs.');
        uint emissionOld = collections[_collectionID].productTokenEmission;
        collections[_collectionID].productTokenEmission = _emission;
        emit eventCollectionChangeEmission(_collectionID, emissionOld, _emission);
    }

    // TODO: emit token
    // TODO: myslet na to, ze nektery NFT mohou emitovat 0 product tokenu

    function collectionRemove(uint _collectionID) public onlyOwner {
        require(_collectionID <= collections.length, 'collectionRemove: Wrong collection ID');
        require(collections[_collectionID].nftCount == 0, 'collectionRemove: Cannot remove collection that has NFTs.');
        delete collections[_collectionID];
        emit eventCollectionsRemove(_collectionID);
    }

    function propertyAdd(uint _collectionID, string memory _name, uint _basicCount) public onlyOwner {
        require(_collectionID <= collections.length, 'propertyAdd: Wrong collection ID');
        properties.push(Collections(_collectionID, _name, _basicCount, block.timestamp));
        emit eventPropertiesAdd(properties.length, _name, _basicCount);
    }

    function propertyRename(uint _propertyID, string memory _name) public onlyOwner {
        require(_propertyID <= properties.length, 'propertyRename: Wrong property ID');
        string memory nameOld = properties[_propertyID].name;
        collections[_propertyID].name = _name;
        emit eventPropertiesRename(_propertyID, nameOld, _name);
    }

    function propertyChangeBasicCount(uint _propertyID, uint _basicCount) public onlyOwner {
        require(_propertyID <= properties.length, 'propertyChangeBasicCount: Wrong property ID');
        require(collections[properties[_propertyID].collectionID].nftCount == 0, 'propertyChangeBasicCount: Cannot remove property, because it was already used in collection that has NFTs.');
        uint basicCountOld = properties[_propertyID].basicCount;
        collections[_propertyID].basicCount = _basicCount;
        emit eventPropertiesChangeBasicCount(_propertyID, basicCountOld, _basicCount);
    }

    function propertyRemove(uint _propertyID) public onlyOwner {
        require(_propertyID <= properties.length, 'propertyRemove: Wrong property ID');
        require(collections[properties[_propertyID].collectionID].nftCount == 0, 'propertyRemove: Cannot remove property, because it was already used in collection that has NFTs.');
        delete properties[_propertyID];
        emit eventPropertiesRemove(_propertyID);
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
}
