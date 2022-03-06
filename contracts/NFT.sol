// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./libs/ERC721MintMore.sol";
import "./libs/IERC20Mint.sol";
import "./libs/SafeERC20Mint.sol";
import "./Marketplace.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

contract NFT is ERC721MintMore, Ownable {
  using SafeERC20Mint for IERC20Mint;
  IERC20Mint public tokenProduct;
  IERC20Mint public tokenUpgrade;
  IERC20Mint public tokenFactory;
  Marketplace public marketplace;
  uint256 private rndCounter;
  uint256 public nftCount;
  uint256 public collectionsCount;
  uint256 public devFeePercent;
  address public devFeeAddress;
  address public burnAddress;
  string public nftName;
  string public nftSymbol;
  mapping(uint256 => Collection) public collections;
  mapping(uint256 => NFTDetails) public nfts;
  event eventTransfer(
    address indexed _fromAddress,
    address indexed _toAddress,
    uint256 indexed _nftID
  );
  event eventNFTRename(
    uint256 indexed _nftID,
    string indexed _nameOld,
    string indexed _nameNew
  );
  event eventNFTSetNFTProperty(
    uint256 indexed _nftID,
    uint256 indexed _valueOld,
    uint256 indexed _value
  );
  event eventNFTLevelUpgrade(
    uint256 indexed _nftID,
    uint256 indexed _levelOld,
    uint256 indexed _levelNew
  );
  event eventNFTHarvestTokenProduct(
    uint256 indexed _nftID,
    address indexed _toAddress,
    uint256 indexed _amount
  );
  event eventFactory(
    uint256 indexed _nftMaleID,
    uint256 indexed _nftFemaleID,
    uint256 indexed _newID
  );
  event eventCollectionAdd(
    uint256 indexed _collectionID,
    string indexed _name,
    uint256 indexed _tokenProductEmission
  );
  event eventCollectionRename(
    uint256 indexed _collectionID,
    string indexed _nameOld,
    string indexed _nameNew
  );
  event eventCollectionSetFactoryTime(
    uint256 indexed _collectionID,
    uint256 indexed _factoryTimeOld,
    uint256 indexed _factoryTimeNew
  );
  event eventCollectionSetTokenProductEmission(
    uint256 _collectionID,
    uint256 indexed _emissionOld,
    uint256 indexed _emissionNew
  );
  event eventCollectionSetTokenUpgradePriceLevel(
    uint256 indexed _collectionID,
    uint256 indexed _priceOld,
    uint256 indexed _price
  );
  event eventCollectionSetTokenUpgradePriceSetProperty(
    uint256 indexed _collectionID,
    uint256 indexed _priceOld,
    uint256 indexed _price
  );
  event eventCollectionSetTokenFactoryPrice(
    uint256 indexed _collectionID,
    uint256 indexed _priceOld,
    uint256 indexed _price
  );
  event eventCollectionRemove(uint256 indexed _collectionID);
  event eventCollectionPropertyAdd(
    uint256 indexed _collectionID,
    uint256 indexed _propertyID,
    string indexed _name
  );
  event eventCollectionPropertyRename(
    uint256 indexed _collectionID,
    uint256 indexed _propertyID,
    string indexed _name
  );
  event eventCollectionPropertySetBasicCount(
    uint256 indexed _collectionID,
    uint256 _propertyID,
    uint256 _basicCount
  );
  event eventCollectionPropertyRemove(
    uint256 indexed _collectionID,
    uint256 indexed _propertyID
  );
  event eventSetDevFeeAddress(
    address indexed devFeeAddressOld,
    address indexed _devFeeAddress
  );

  struct Collection {
    bool exists;
    string name;
    uint256 factoryTime; // 50400 = 1 day
    uint256 tokenProductEmission;
    uint256 tokenUpgradePriceLevel;
    uint256 tokenUpgradePriceSetProperty;
    uint256 tokenFactoryPrice;
    Property[] properties;
    uint256 nftCount;
    uint256 createdTime;
  }

  struct Property {
    string name;
    uint256 basicCount;
    uint256 createdTime;
  }

  struct NFTDetails {
    bool exists;
    bool sex;
    bool hasParents;
    uint256 parentMaleID;
    uint256 parentFemaleID;
    string name;
    uint256 collectionID;
    uint256 level;
    uint256 lastEmissionBlock;
    uint256[] properties;
    uint256 createdTime;
  }

  constructor(
    string memory _nftName,
    string memory _nftSymbol,
    uint256 _devFeePercent,
    address _devFeeAddress,
    address _burnAddress,
    address _marketplaceAddress,
    address _tokenFactoryAddress,
    address _tokenProductAddress,
    address _tokenUpgradeAddress
  ) ERC721MintMore(_nftName, _nftSymbol) {
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

  function transfer(
    address _fromAddress,
    address _toAddress,
    uint256 _nftID
  ) public {
    require(
      _isApprovedOrOwner(msg.sender, _nftID) == true,
      "transfer: You are not the owner of this NFT"
    );
    // require(
    //   ownerOf(_nftID) == msg.sender,
    //   "transfer: You are not the owner of this NFT"
    // );
    nftHarvestTokenProduct(_nftID);
    safeTransferFrom(_fromAddress, _toAddress, _nftID);
    //safeTransferFrom(_fromAddress, address(this), _nftID);
    //transferFrom(address(this), _toAddress, _nftID);
    emit eventTransfer(_fromAddress, _toAddress, _nftID);
  }

  function nftRename(uint256 _nftID, string memory _name) public {
    require(nfts[_nftID].exists, "nftRename: Wrong NFT ID");
    require(
      ownerOf(_nftID) == msg.sender,
      "nftRename: You are not the owner of this NFT"
    );
    require(
      getUTFStrLen(_name) <= 16,
      "nftRename: Name is too long. Maximum: 16 characters"
    );
    require(
      getCharMatch(_name),
      "nftRename: Name can contain only a-z, A-Z, 0-9, space and dot"
    );
    string memory nameOld = nfts[_nftID].name;
    nfts[_nftID].name = _name;
    emit eventNFTRename(_nftID, nameOld, _name);
  }

  function nftLevelUpgrade(uint256 _nftID, uint256 _levels) public {
    require(nfts[_nftID].exists, "nftLevelUpgrade: Wrong NFT ID");
    uint256 amount = _levels *
      collections[nfts[_nftID].collectionID].tokenUpgradePriceLevel;
    require(
      tokenUpgrade.allowance(msg.sender, address(this)) >= amount,
      "nftLevelUpgrade: Token Upgrade allowance is too low"
    );
    require(
      tokenUpgrade.balanceOf(msg.sender) >= amount,
      "nftLevelUpgrade: Not enough Token Upgrade in your wallet"
    );
    tokenUpgrade.safeTransferFrom(msg.sender, address(this), amount);
    tokenUpgrade.safeTransfer(devFeeAddress, (amount * devFeePercent) / 10000);
    tokenUpgrade.safeTransfer(
      burnAddress,
      (amount * (10000 - devFeePercent)) / 10000
    );
    nftHarvestTokenProduct(_nftID);
    uint256 levelOld = nfts[_nftID].level;
    nfts[_nftID].level += _levels;
    emit eventNFTLevelUpgrade(_nftID, levelOld, nfts[_nftID].level);
  }

  function nftSetProperty(
    uint256 _nftID,
    uint256 _propertyID,
    uint256 _value
  ) public {
    require(nfts[_nftID].exists, "nftSetProperty: Wrong NFT ID");
    require(
      ownerOf(_nftID) == msg.sender,
      "nftSetProperty: You are not the owner of this NFT"
    );
    require(
      collections[nfts[_nftID].collectionID].properties.length >= _propertyID,
      "nftSetProperty: Property does not exist"
    );
    require(
      collections[nfts[_nftID].collectionID]
        .properties[_propertyID]
        .basicCount <= _value,
      "nftSetProperty: This property is not available"
    );
    uint256 amount = collections[nfts[_nftID].collectionID]
      .tokenUpgradePriceSetProperty;
    require(
      tokenUpgrade.allowance(msg.sender, address(this)) >= amount,
      "nftSetProperty: Token Upgrade allowance is too low"
    );
    require(
      tokenUpgrade.balanceOf(msg.sender) >= amount,
      "nftSetProperty: Not enough Token Upgrade in your wallet"
    );
    tokenUpgrade.safeTransferFrom(msg.sender, address(this), amount);
    tokenUpgrade.safeTransfer(devFeeAddress, (amount * devFeePercent) / 10000);
    tokenUpgrade.safeTransfer(
      burnAddress,
      (amount * (10000 - devFeePercent)) / 10000
    );
    uint256 valueOld = nfts[_nftID].properties[_propertyID];
    nfts[_nftID].properties[_propertyID] = _value;
    emit eventNFTSetNFTProperty(_nftID, valueOld, _value);
  }

  function nftHarvestTokenProduct(uint256 _nftID) public {
    uint256 toHarvest = getTokenProductToHarvest(_nftID);
    if (ownerOf(_nftID) != owner()) {
      tokenProduct.mint(toHarvest);
      tokenProduct.safeTransfer(ownerOf(_nftID), toHarvest);
    }
    nfts[_nftID].lastEmissionBlock = block.number;
    emit eventNFTHarvestTokenProduct(_nftID, msg.sender, toHarvest);
  }

  function getTokenProductToHarvest(uint256 _nftID)
    public
    view
    returns (uint256)
  {
    if (ownerOf(_nftID) != owner()) return 0;
    else
      return
        (block.number - nfts[_nftID].lastEmissionBlock) *
        nfts[_nftID].level *
        collections[nfts[_nftID].collectionID].tokenProductEmission;
  }

  function mint(
    address _recipient,
    uint256 _collectionID,
    string memory _name,
    bool _hasParents,
    uint256 _parentMaleID,
    uint256 _parentFemaleID
  ) public onlyOwner returns (uint256) {
    require(collections[_collectionID].exists, "mint: Wrong collection ID");
    require(
      collections[_collectionID].properties.length > 0,
      "mint: This collection has no properties"
    );
    require(
      getUTFStrLen(_name) <= 16,
      "mint: Name is too long. Maximum: 16 characters"
    );
    require(
      getCharMatch(_name),
      "mint: Name can contain only a-z, A-Z, 0-9, space and dot"
    );
    if (_hasParents) {
      require(nfts[_parentMaleID].exists, "mint: parentMaleID does not exist");
      require(
        nfts[_parentMaleID].collectionID == _collectionID,
        "mint: parentMaleID is from different collection"
      );
      require(
        nfts[_parentMaleID].sex,
        "mint: parentMaleID does not refer to male NFT"
      );
      require(
        nfts[_parentFemaleID].exists,
        "mint: parentFemaleID does not exist"
      );
      require(
        nfts[_parentFemaleID].collectionID == _collectionID,
        "mint: parentFemaleID is from different collection"
      );
      require(
        !nfts[_parentFemaleID].sex,
        "mint: parentFemaleID does not refer to female NFT"
      );
    } else {
      require(_parentMaleID == 0, "mint: parentMaleID has to be 0");
      require(_parentFemaleID == 0, "mint: parentFemaleID has to be 0");
    }
    _safeMint(_recipient, nftCount);
    mintAddDetails(
      _collectionID,
      _name,
      _hasParents,
      _parentMaleID,
      _parentFemaleID
    );
    return nftCount - 1;
  }

  function mintMore(
    address _recipient,
    uint256 _collectionID,
    string memory _name,
    uint256 _count
  ) public onlyOwner returns (uint256) {
    require(collections[_collectionID].exists, "mintMore: Wrong collection ID");
    require(
      collections[_collectionID].properties.length > 0,
      "mintMore: This collection has no properties"
    );
    require(
      getUTFStrLen(_name) <= 16,
      "mintMore: Name is too long. Maximum: 16 characters"
    );
    require(
      getCharMatch(_name),
      "mintMore: Name can contain only a-z, A-Z, 0-9, space and dot"
    );
    _mintMore(_recipient, nftCount, _count);
    for (uint256 i = 0; i < _count; i++)
      mintAddDetails(
        _collectionID,
        string(abi.encodePacked(_name, " ", Strings.toString(nftCount + 1))),
        false,
        0,
        0
      );
    return nftCount - 1;
  }

  function mintToMarketplace(
    uint256 _collectionID,
    string memory _name,
    uint256 _price
  ) public onlyOwner {
    uint256 nftID = mint(address(this), _collectionID, _name, false, 0, 0);
    _approve(address(marketplace), nftID);
    marketplace.deposit(address(this), nftID, _price);
  }

  function mintMoreToMarketplace(
    uint256 _collectionID,
    string memory _name,
    uint256 _price,
    uint256 _count
  ) public onlyOwner {
    uint256 startID = nftCount;
    mintMore(address(this), _collectionID, _name, _count);
    for (uint256 i = 0; i < _count; i++)
      marketplace.deposit(address(this), startID + i, _price);
  }

  function mintAddDetails(
    uint256 _collectionID,
    string memory _name,
    bool _hasParents,
    uint256 _parentMaleID,
    uint256 _parentFemaleID
  ) private onlyOwner {
    nfts[nftCount].exists = true;
    nfts[nftCount].sex = getRandomNumber(2) == 1 ? true : false;
    nfts[nftCount].hasParents = _hasParents;
    nfts[nftCount].parentMaleID = _parentMaleID;
    nfts[nftCount].parentFemaleID = _parentFemaleID;
    nfts[nftCount].name = _name;
    nfts[nftCount].collectionID = _collectionID;
    nfts[nftCount].level = 1;
    nfts[nftCount].lastEmissionBlock = block.number;
    for (uint256 i = 0; i < collections[_collectionID].properties.length; i++) {
      nfts[nftCount].properties.push(
        getRandomNumber(collections[_collectionID].properties[i].basicCount)
      );
    }
    nfts[nftCount].createdTime = block.timestamp;
    collections[_collectionID].nftCount++;
    nftCount++;
  }

  function factory(
    uint256 _nftMaleID,
    uint256 _nftFemaleID,
    string memory _name
  ) public {
    require(
      ownerOf(_nftMaleID) == msg.sender,
      "factory: First ID is not in your wallet"
    );
    require(
      ownerOf(_nftFemaleID) == msg.sender,
      "factory: Second ID is not in your wallet"
    );
    require(
      nfts[_nftMaleID].collectionID == nfts[_nftFemaleID].collectionID,
      "factory: Male ID and female ID are not from the same collection."
    );
    require(nfts[_nftMaleID].sex, "factory: First ID is not male");
    require(!nfts[_nftFemaleID].sex, "factory: Second ID is not female");
    require(
      nfts[_nftMaleID].createdTime +
        collections[nfts[_nftMaleID].collectionID].factoryTime <
        block.timestamp,
      "factory: Male NFT is too young"
    );
    require(
      nfts[_nftFemaleID].createdTime +
        collections[nfts[_nftFemaleID].collectionID].factoryTime <
        block.timestamp,
      "factory: Female NFT is too young"
    );
    tokenFactory.safeTransferFrom(
      msg.sender,
      address(this),
      collections[nfts[_nftMaleID].collectionID].tokenFactoryPrice
    );
    tokenFactory.safeTransfer(
      devFeeAddress,
      (collections[nfts[_nftMaleID].collectionID].tokenFactoryPrice *
        devFeePercent) / 10000
    );
    tokenFactory.safeTransfer(
      burnAddress,
      (collections[nfts[_nftMaleID].collectionID].tokenFactoryPrice *
        (10000 - devFeePercent)) / 10000
    );
    uint256 newID = mint(
      msg.sender,
      nfts[_nftMaleID].collectionID,
      _name,
      true,
      _nftMaleID,
      _nftFemaleID
    );
    emit eventFactory(_nftMaleID, _nftFemaleID, newID);
  }

  function getNFTProperty(uint256 _nftID, uint256 _propertyID)
    public
    view
    returns (uint256)
  {
    require(nfts[_nftID].exists, "getNFTProperty: Wrong NFT ID");
    require(
      _propertyID < collections[nfts[_nftID].collectionID].properties.length,
      "getNFTProperty: Wrong property ID"
    );
    return nfts[_nftID].properties[_propertyID];
  }

  function getCollectionProperty(uint256 _collectionID, uint256 _propertyID)
    public
    view
    returns (Property memory)
  {
    require(
      collections[_collectionID].exists,
      "getCollectionProperty: Wrong collection ID"
    );
    require(
      _propertyID < collections[_collectionID].properties.length,
      "getCollectionProperty: Wrong property ID"
    );
    return collections[_collectionID].properties[_propertyID];
  }

  function collectionAdd(
    string memory _name,
    uint256 _factoryTime,
    uint256 _tokenProductEmission,
    uint256 _tokenUpgradePriceLevel,
    uint256 _tokenUpgradePriceSetProperty,
    uint256 _tokenFactoryPrice
  ) public onlyOwner returns (uint256) {
    collections[collectionsCount].exists = true;
    collections[collectionsCount].name = _name;
    collections[collectionsCount].factoryTime = _factoryTime;
    collections[collectionsCount].tokenProductEmission = _tokenProductEmission;
    collections[collectionsCount]
      .tokenUpgradePriceLevel = _tokenUpgradePriceLevel;
    collections[collectionsCount]
      .tokenUpgradePriceSetProperty = _tokenUpgradePriceSetProperty;
    collections[collectionsCount].tokenFactoryPrice = _tokenFactoryPrice;
    collections[collectionsCount].nftCount = 0;
    collections[collectionsCount].createdTime = block.timestamp;
    collectionsCount++;
    emit eventCollectionAdd(collectionsCount - 1, _name, _tokenProductEmission);
    return collectionsCount - 1;
  }

  function collectionRename(uint256 _collectionID, string memory _name)
    public
    onlyOwner
  {
    require(
      collections[_collectionID].exists,
      "collectionRename: Wrong collection ID"
    );
    string memory nameOld = collections[_collectionID].name;
    collections[_collectionID].name = _name;
    emit eventCollectionRename(_collectionID, nameOld, _name);
  }

  function collectionSetFactoryTime(uint256 _collectionID, uint256 _factoryTime)
    public
    onlyOwner
  {
    require(
      collections[_collectionID].exists,
      "collectionSetFactoryTime: Wrong collection ID"
    );
    require(
      collections[_collectionID].nftCount == 0,
      "collectionSetFactoryTime: Cannot set factory time in collection that has NFTs."
    );
    uint256 factoryTimeOld = collections[_collectionID].factoryTime;
    collections[_collectionID].factoryTime = _factoryTime;
    emit eventCollectionSetFactoryTime(
      _collectionID,
      factoryTimeOld,
      _factoryTime
    );
  }

  function collectionSetTokenProductEmission(
    uint256 _collectionID,
    uint256 _emission
  ) public onlyOwner {
    require(
      collections[_collectionID].exists,
      "collectionSetTokenProductEmission: Wrong collection ID"
    );
    require(
      collections[_collectionID].nftCount == 0,
      "collectionSetTokenProductEmission: Cannot set token Product emission in collection that has NFTs."
    );
    uint256 emissionOld = collections[_collectionID].tokenProductEmission;
    collections[_collectionID].tokenProductEmission = _emission;
    emit eventCollectionSetTokenProductEmission(
      _collectionID,
      emissionOld,
      _emission
    );
  }

  function collectionSetTokenUpgradePriceLevel(
    uint256 _collectionID,
    uint256 _price
  ) public onlyOwner {
    require(
      collections[_collectionID].exists,
      "collectionSetTokenUpgradePriceLevel: Wrong collection ID"
    );
    require(
      collections[_collectionID].nftCount == 0,
      "collectionSetTokenUpgradePriceLevel: Cannot set token Upgrade price in collection that has NFTs."
    );
    uint256 priceOld = collections[_collectionID].tokenUpgradePriceLevel;
    collections[_collectionID].tokenUpgradePriceLevel = _price;
    emit eventCollectionSetTokenUpgradePriceLevel(
      _collectionID,
      priceOld,
      _price
    );
  }

  function collectionSetTokenUpgradePriceSetProperty(
    uint256 _collectionID,
    uint256 _price
  ) public onlyOwner {
    require(
      collections[_collectionID].exists,
      "collectionSetTokenUpgradePriceSetProperty: Wrong collection ID"
    );
    require(
      collections[_collectionID].nftCount == 0,
      "collectionSetTokenUpgradePriceSetProperty: Cannot set token Upgrade price in collection that has NFTs."
    );
    uint256 priceOld = collections[_collectionID].tokenUpgradePriceSetProperty;
    collections[_collectionID].tokenUpgradePriceSetProperty = _price;
    emit eventCollectionSetTokenUpgradePriceSetProperty(
      _collectionID,
      priceOld,
      _price
    );
  }

  function collectionSetTokenFactoryPrice(uint256 _collectionID, uint256 _price)
    public
    onlyOwner
  {
    require(
      collections[_collectionID].exists,
      "collectionSetTokenFactoryPrice: Wrong collection ID"
    );
    require(
      collections[_collectionID].nftCount == 0,
      "collectionSetTokenFactoryPrice: Cannot set token Upgrade price in collection that has NFTs."
    );
    uint256 priceOld = collections[_collectionID].tokenFactoryPrice;
    collections[_collectionID].tokenFactoryPrice = _price;
    emit eventCollectionSetTokenFactoryPrice(_collectionID, priceOld, _price);
  }

  function collectionRemove(uint256 _collectionID) public onlyOwner {
    require(
      collections[_collectionID].exists,
      "collectionRemove: Wrong collection ID"
    );
    require(
      collections[_collectionID].nftCount == 0,
      "collectionRemove: Cannot remove collection that has NFTs."
    );
    delete collections[_collectionID];
    emit eventCollectionRemove(_collectionID);
  }

  function collectionPropertyAdd(
    uint256 _collectionID,
    string memory _name,
    uint256 _basicCount
  ) public onlyOwner {
    require(
      collections[_collectionID].exists,
      "collectionPropertyAdd: Wrong collection ID"
    );
    require(
      collections[_collectionID].nftCount == 0,
      "collectionPropertyAdd: Cannot add property, because it was already used in collection that has NFTs."
    );
    collections[_collectionID].properties.push(
      Property(_name, _basicCount, block.timestamp)
    );
    emit eventCollectionPropertyAdd(
      _collectionID,
      collections[_collectionID].properties.length - 1,
      _name
    );
  }

  function collectionPropertyRename(
    uint256 _collectionID,
    uint256 _propertyID,
    string memory _name
  ) public onlyOwner {
    require(
      collections[_collectionID].exists,
      "collectionPropertyRename: Wrong collection ID"
    );
    require(
      _propertyID < collections[_collectionID].properties.length,
      "collectionPropertyRename: Wrong property ID"
    );
    collections[_propertyID].name = _name;
    emit eventCollectionPropertyRename(_collectionID, _propertyID, _name);
  }

  function collectionPropertySetBasicCount(
    uint256 _collectionID,
    uint256 _propertyID,
    uint256 _basicCount
  ) public onlyOwner {
    require(
      collections[_collectionID].exists,
      "collectionPropertySetBasicCount: Wrong collection ID"
    );
    require(
      _propertyID < collections[_collectionID].properties.length,
      "collectionPropertySetBasicCount: Wrong property ID"
    );
    require(
      collections[_collectionID].nftCount == 0,
      "collectionPropertySetBasicCount: Cannot remove property, because it was already used in collection that has NFTs."
    );
    collections[_collectionID].properties[_propertyID].basicCount = _basicCount;
    emit eventCollectionPropertySetBasicCount(
      _collectionID,
      _propertyID,
      _basicCount
    );
  }

  function collectionPropertyRemove(uint256 _collectionID, uint256 _propertyID)
    public
    onlyOwner
  {
    require(
      collections[_collectionID].exists,
      "collectionPropertyRemove: Wrong collection ID"
    );
    require(
      _propertyID < collections[_collectionID].properties.length,
      "collectionPropertyRemove: Wrong property ID"
    );
    require(
      collections[_collectionID].nftCount == 0,
      "collectionPropertyRemove: Cannot remove property, because it was already used in collection that has NFTs."
    );
    delete collections[_collectionID].properties[_propertyID];
    emit eventCollectionPropertyRemove(_collectionID, _propertyID);
  }

  function getRandomNumber(uint256 _num) private returns (uint256) {
    if (rndCounter == 2**256 - 1) rndCounter = 0;
    else rndCounter++;
    return
      uint256(
        uint256(keccak256(abi.encodePacked(block.timestamp, rndCounter))) % _num
      );
  }

  function getUTFStrLen(string memory str) internal pure returns (uint256) {
    uint256 length = 0;
    uint256 i = 0;
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

  function getCharMatch(string memory str) internal pure returns (bool) {
    // ASCII table: https://www.asciitable.com/
    bytes memory b = bytes(str);
    for (uint256 i; i < b.length; i++) {
      bytes1 char = b[i];
      if (
        !(char >= 0x61 && char <= 0x7A) && // a-z
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

  function onERC721Received(
    address operator,
    address from,
    uint256 tokenId,
    bytes calldata data
  ) public pure returns (bytes4) {
    return IERC721Receiver.onERC721Received.selector;
  }
}
