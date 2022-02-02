// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

//import './IERC20Mint.sol';
//import '@openzeppelin/contracts/utils/Address.sol';
import './INFT.sol';
import '@openzeppelin/contracts/access/Ownable.sol';

library CollectionManager is Ownable {
    event eventCollectionAdd(uint indexed _collectionID, string indexed _name, uint indexed _tokenProductEmission);
    event eventCollectionRename(uint indexed _collectionID, string indexed _nameOld, string indexed _nameNew);
    event eventCollectionSetFactoryTime(uint indexed _collectionID, uint indexed _factoryTimeOld, uint indexed _factoryTimeNew);
    event eventCollectionSetTokenProductEmission(uint _collectionID, uint indexed _emissionOld, uint indexed _emissionNew);
    event eventCollectionSetTokenUpgradePrice(uint indexed _collectionID, uint indexed _priceOld, uint indexed _price);
    event eventCollectionSetTokenFactoryPrice(uint indexed _collectionID, uint indexed _priceOld, uint indexed _price);
    event eventCollectionRemove(uint indexed _collectionID);
    event eventCollectionPropertyAdd(uint indexed _collectionID, uint indexed _propertyID, string indexed _name);
    event eventCollectionPropertyRename(uint indexed _collectionID, uint indexed _propertyID, string indexed _name);
    event eventCollectionPropertySetBasicCount(uint indexed _collectionID, uint _propertyID, uint _basicCount);
    event eventCollectionPropertyRemove(uint indexed _collectionID, uint indexed _propertyID);

    function collectionAdd(INFT nft, string memory _name, uint _factoryTime, uint _tokenProductEmission, uint _tokenUpgradePrice, uint _tokenFactoryPrice) public onlyOwner returns (uint) {
        nft.collections[nft.collectionsCount].exists = true;
        nft.collections[nft.collectionsCount].name = _name;
        nft.collections[nft.collectionsCount].factoryTime = _factoryTime;
        nft.collections[nft.collectionsCount].tokenProductEmission = _tokenProductEmission;
        nft.collections[nft.collectionsCount].tokenUpgradePrice = _tokenUpgradePrice;
        nft.collections[nft.collectionsCount].tokenFactoryPrice = _tokenFactoryPrice;
        nft.collections[nft.collectionsCount].nftCount = 0;
        nft.collections[nft.collectionsCount].createdTime = block.timestamp;
        nft.collectionsCount++;
        emit eventCollectionAdd(nft.collectionsCount - 1, _name, _tokenProductEmission);
        return nft.collectionsCount - 1;
    }
/* // TODO: docasne vyhozeno pro test, abych vsude nedaval "nft."
    function collectionRename(uint _collectionID, string memory _name) public onlyOwner {
        require(collections[_collectionID].exists, 'collectionRename: Wrong collection ID');
        string memory nameOld = collections[_collectionID].name;
        collections[_collectionID].name = _name;
        emit eventCollectionRename(_collectionID, nameOld, _name);
    }

    function collectionSetFactoryTime(uint _collectionID, uint _factoryTime) public onlyOwner {
        require(collections[_collectionID].exists, 'collectionSetFactoryTime: Wrong collection ID');
        require(collections[_collectionID].nftCount == 0, 'collectionSetFactoryTime: Cannot set factory time in collection that has NFTs.');
        uint factoryTimeOld = collections[_collectionID].factoryTime;
        collections[_collectionID].factoryTime = _factoryTime;
        emit eventCollectionSetFactoryTime(_collectionID, factoryTimeOld, _factoryTime);
    }

    function collectionSetTokenProductEmission(uint _collectionID, uint _emission) public onlyOwner {
        require(collections[_collectionID].exists, 'collectionSetTokenProductEmission: Wrong collection ID');
        require(collections[_collectionID].nftCount == 0, 'collectionSetTokenProductEmission: Cannot set token Product emission in collection that has NFTs.');
        uint emissionOld = collections[_collectionID].tokenProductEmission;
        collections[_collectionID].tokenProductEmission = _emission;
        emit eventCollectionSetTokenProductEmission(_collectionID, emissionOld, _emission);
    }

    function collectionSetTokenUpgradePrice(uint _collectionID, uint _price) public onlyOwner {
        require(collections[_collectionID].exists, 'collectionSetTokenUpgradePrice: Wrong collection ID');
        require(collections[_collectionID].nftCount == 0, 'collectionSetTokenUpgradePrice: Cannot set token Upgrade price in collection that has NFTs.');
        uint priceOld = collections[_collectionID].tokenUpgradePrice;
        collections[_collectionID].tokenUpgradePrice = _price;
        emit eventCollectionSetTokenUpgradePrice(_collectionID, priceOld, _price);
    }

    function collectionSetTokenFactoryPrice(uint _collectionID, uint _price) public onlyOwner {
        require(collections[_collectionID].exists, 'collectionSetTokenFactoryPrice: Wrong collection ID');
        require(collections[_collectionID].nftCount == 0, 'collectionSetTokenFactoryPrice: Cannot set token Upgrade price in collection that has NFTs.');
        uint priceOld = collections[_collectionID].tokenFactoryPrice;
        collections[_collectionID].tokenFactoryPrice = _price;
        emit eventCollectionSetTokenFactoryPrice(_collectionID, priceOld, _price);
    }

    function collectionRemove(uint _collectionID) public onlyOwner {
        require(collections[_collectionID].exists, 'collectionRemove: Wrong collection ID');
        require(collections[_collectionID].nftCount == 0, 'collectionRemove: Cannot remove collection that has NFTs.');
        delete collections[_collectionID];
        emit eventCollectionRemove(_collectionID);
    }

    function collectionPropertyAdd(uint _collectionID, string memory _name, uint _basicCount) public onlyOwner {
        require(collections[_collectionID].exists, 'collectionPropertyAdd: Wrong collection ID');
        require(collections[_collectionID].nftCount == 0, 'collectionPropertyAdd: Cannot add property, because it was already used in collection that has NFTs.');
        collections[_collectionID].properties.push(Property(_name, _basicCount, block.timestamp));
        emit eventCollectionPropertyAdd(_collectionID, collections[_collectionID].properties.length - 1, _name);
    }

    function collectionPropertyRename(uint _collectionID, uint _propertyID, string memory _name) public onlyOwner {
        require(collections[_collectionID].exists, 'collectionPropertyRename: Wrong collection ID');
        require(_propertyID <= collections[_collectionID].properties.length, 'collectionPropertyRename: Wrong property ID');
        collections[_propertyID].name = _name;
        emit eventCollectionPropertyRename(_collectionID, _propertyID, _name);
    }

    function collectionPropertySetBasicCount(uint _collectionID, uint _propertyID, uint _basicCount) public onlyOwner {
        require(collections[_collectionID].exists, 'collectionPropertySetBasicCount: Wrong collection ID');
        require(_propertyID <= collections[_collectionID].properties.length, 'collectionPropertySetBasicCount: Wrong property ID');
        require(collections[_collectionID].nftCount == 0, 'collectionPropertySetBasicCount: Cannot remove property, because it was already used in collection that has NFTs.');
        collections[_collectionID].properties[_propertyID].basicCount = _basicCount;
        emit eventCollectionPropertySetBasicCount(_collectionID, _propertyID, _basicCount);
    }

    function collectionPropertyRemove(uint _collectionID, uint _propertyID) public onlyOwner {
        require(collections[_collectionID].exists, 'collectionPropertyRemove: Wrong collection ID');
        require(_propertyID <= collections[_collectionID].properties.length, 'collectionPropertyRemove: Wrong property ID');
        require(collections[_collectionID].nftCount == 0, 'collectionPropertyRemove: Cannot remove property, because it was already used in collection that has NFTs.');
        delete collections[_collectionID].properties[_propertyID];
        emit eventCollectionPropertyRemove(_collectionID, _propertyID);
    }
*/
}