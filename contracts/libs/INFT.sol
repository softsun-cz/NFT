// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface INFT {
  struct Property {
    string name;
    uint256 basicCount;
    uint256 createdTime;
  }

  function balanceOf(address owner) external view returns (uint256 balance);

  function ownerOf(uint256 tokenId) external view returns (address owner);

  function safeTransferFrom(address from, address to, uint256 tokenId) external;

  function transferFrom(address from, address to, uint256 tokenId) external;

  function approve(address to, uint256 tokenId) external;

  function getApproved(uint256 tokenId) external view returns (address operator);

  function setApprovalForAll(address operator, bool _approved) external;

  function isApprovedForAll(address owner, address operator) external view returns (bool);

  function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

  function totalSupply() external view returns (uint256);

  function transfer(address _fromAddress, address _toAddress, uint256 _nftID) external;

  function nftRename(uint256 _nftID, string memory _name) external;

  function nftLevelUpgrade(uint256 _nftID, uint256 _levels) external;

  function nftSetProperty(uint256 _nftID, uint256 _propertyID, uint256 _value) external;

  function nftHarvestTokenProduct(uint256 _nftID) external;

  function getTokenProductToHarvest(uint256 _nftID) external view returns (uint256);

  function mint(address _recipient, uint256 _collectionID, string memory _name, bool _hasParents, uint256 _parentMaleID, uint256 _parentFemaleID) external returns (uint256);

  function mintMore(address _recipient, uint256 _collectionID, string memory _name, uint256 _count) external returns (uint256);

  function mintToMarketplace(uint256 _collectionID, string memory _name, uint256 _price) external;

  function mintMoreToMarketplace(uint256 _collectionID, string memory _name, uint256 _price, uint256 _count) external;

  function factory(uint256 _nftMaleID, uint256 _nftFemaleID, string memory _name) external;

  function getNFTProperty(uint256 _nftID, uint256 _propertyID) external view returns (uint256);

  function getCollectionProperty(uint256 _collectionID, uint256 _propertyID) external view returns (Property memory);

  function collectionAdd(string memory _name, uint256 _factoryTime, uint256 _tokenProductEmission, uint256 _tokenUpgradePriceLevel, uint256 _tokenUpgradePriceSetProperty, uint256 _tokenFactoryPrice) external returns (uint256);

  function collectionRename(uint256 _collectionID, string memory _name) external;

  function collectionSetFactoryTime(uint256 _collectionID, uint256 _factoryTime) external;

  function collectionSetTokenProductEmission(uint256 _collectionID, uint256 _emission) external;

  function collectionSetTokenUpgradePriceLevel(uint256 _collectionID, uint256 _price) external;

  function collectionSetTokenUpgradePriceSetProperty(uint256 _collectionID, uint256 _price) external;

  function collectionSetTokenFactoryPrice(uint256 _collectionID, uint256 _price) external;

  function collectionRemove(uint256 _collectionID) external;

  function collectionPropertyAdd(uint256 _collectionID, string memory _name, uint256 _basicCount) external;

  function collectionPropertyRename(uint256 _collectionID, uint256 _propertyID, string memory _name) external;

  function collectionPropertySetBasicCount(uint256 _collectionID, uint256 _propertyID, uint256 _basicCount) external;

  function collectionPropertyRemove(uint256 _collectionID, uint256 _propertyID) external;

  function setDevFeeAddress(address _devFeeAddress) external;

  event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
  event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
  event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
  event eventTransfer(address indexed _fromAddress, address indexed _toAddress, uint256 indexed _nftID);
  event eventNFTRename(uint256 indexed _nftID, string indexed _nameOld, string indexed _nameNew);
  event eventNFTSetNFTProperty(uint256 indexed _nftID, uint256 indexed _valueOld, uint256 indexed _value);
  event eventNFTLevelUpgrade(uint256 indexed _nftID, uint256 indexed _levelOld, uint256 indexed _levelNew);
  event eventNFTHarvestTokenProduct(uint256 indexed _nftID, address indexed _toAddress, uint256 indexed _amount);
  event eventFactory(uint256 indexed _nftMaleID, uint256 indexed _nftFemaleID, uint256 indexed _newID);
  event eventCollectionAdd(uint256 indexed _collectionID, string indexed _name, uint256 indexed _tokenProductEmission);
  event eventCollectionRename(uint256 indexed _collectionID, string indexed _nameOld, string indexed _nameNew);
  event eventCollectionSetFactoryTime(uint256 indexed _collectionID, uint256 indexed _factoryTimeOld, uint256 indexed _factoryTimeNew);
  event eventCollectionSetTokenProductEmission(uint256 _collectionID, uint256 indexed _emissionOld, uint256 indexed _emissionNew);
  event eventCollectionSetTokenUpgradePriceLevel(uint256 indexed _collectionID, uint256 indexed _priceOld, uint256 indexed _price);
  event eventCollectionSetTokenUpgradePriceSetProperty(uint256 indexed _collectionID, uint256 indexed _priceOld, uint256 indexed _price);
  event eventCollectionSetTokenFactoryPrice(uint256 indexed _collectionID, uint256 indexed _priceOld, uint256 indexed _price);
  event eventCollectionRemove(uint256 indexed _collectionID);
  event eventCollectionPropertyAdd(uint256 indexed _collectionID, uint256 indexed _propertyID, string indexed _name);
  event eventCollectionPropertyRename(uint256 indexed _collectionID, uint256 indexed _propertyID, string indexed _name);
  event eventCollectionPropertySetBasicCount(uint256 indexed _collectionID, uint256 _propertyID, uint256 _basicCount);
  event eventCollectionPropertyRemove(uint256 indexed _collectionID, uint256 indexed _propertyID);
  event eventSetDevFeeAddress(address indexed devFeeAddressOld, address indexed _devFeeAddress);
}
