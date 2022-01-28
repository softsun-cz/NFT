// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import '@openzeppelin/contracts/token/ERC721/IERC721.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import "@openzeppelin/contracts/access/Ownable.sol";
import '@openzeppelin/contracts/security/ReentrancyGuard.sol';

contract Marketplace is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;
    IERC20 currency;
    address devFeeAddress;
    uint16 devFeePercent;
    uint totalDeposit;
    uint totalWithdraw;
    uint totalBuy;
    uint totalChangePrice;
    mapping (address => bool) public acceptedContracts;
    Details[] deposited;
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

    constructor(address _currencyAddress, uint16 _devFeePercent) {
        currency = IERC20(_currencyAddress);
        devFeeAddress = msg.sender;
        devFeePercent = _devFeePercent;
    }
    
    function deposit(address _addressContract, uint _tokenID, uint _price) public nonReentrant {
        IERC721 nft = IERC721(_addressContract);
        require(nft.getApproved(_tokenID) == address(this), 'deposit: Allowance is too low');
        require(acceptedContracts[_addressContract], 'deposit: this NFT is not accepted by this Marketplace');
        nft.safeTransferFrom(msg.sender, address(this), _tokenID);
        deposited.push(Details(address(nft), _tokenID, msg.sender, _price));
        totalDeposit++;
        emit eventDeposit(totalDeposit, Deposit(_addressContract, _tokenID, msg.sender, _price, block.timestamp));
    }

    function withdraw(uint _id) public nonReentrant {
        // TODO: check if array exists
        require(deposited[_id].owner == msg.sender, 'withdraw: You are not the owner of this NFT');
        IERC721 nft = IERC721(deposited[_id].addressContract);
        nft.safeTransferFrom(address(this), msg.sender, deposited[_id].tokenID);
        // TODO: remove element from mapping (not possible, try array instead?)
        totalWithdraw++;
        emit eventWithdraw(totalWithdraw, Withdraw(deposited[_id].addressContract, deposited[_id].tokenID, deposited[_id].owner, deposited[_id].price, block.timestamp));
        delete deposited[_id];
    }

    function buy(uint _id) public nonReentrant {
        IERC721 nft = IERC721(deposited[_id].addressContract);
        require(currency.allowance(msg.sender, address(this)) >= deposited[_id].price, 'buy: Currency allowance is too low');
        require(nft.getApproved(deposited[_id].tokenID) != address(0), 'buy: This NFT is not approved');
        currency.safeTransferFrom(msg.sender, address(this), deposited[_id].price);
        currency.safeTransfer(deposited[_id].owner, deposited[_id].price * (10000 - devFeePercent) / 10000);
        currency.safeTransfer(devFeeAddress, deposited[_id].price * devFeePercent / 10000);
        nft.safeTransferFrom(address(this), msg.sender, deposited[_id].tokenID);
        totalBuy++;
        emit eventBuy(totalBuy, Buy(deposited[_id].addressContract, deposited[_id].tokenID, deposited[_id].owner, msg.sender, deposited[_id].price, block.timestamp));
        delete deposited[_id];
    }

    function changePrice(uint _id, uint _priceNew) public nonReentrant {
        require(deposited[_id].owner == msg.sender, 'changePrice: You are not the owner of this NFT');
        uint priceOld = deposited[_id].price;
        deposited[_id].price = _priceNew;
        totalChangePrice++;
        emit eventChangePrice(totalChangePrice, ChangePrice(deposited[_id].addressContract, deposited[_id].tokenID, deposited[_id].owner, priceOld, _priceNew, block.timestamp));
    }

    function addAcceptedContract(address _addressContract) public onlyOwner {
        acceptedContracts[_addressContract] = true;
    }

    function setDevFeeAddress(address _devFeeAddress) public onlyOwner {
        devFeeAddress = _devFeeAddress;
    }
}
