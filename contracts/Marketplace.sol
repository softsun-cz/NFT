// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import './libs/INFT.sol';
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
    mapping (address => bool) public acceptedContracts;
    Details[] deposited;
    event eventDeposit(uint indexed _depositID, Deposit indexed _deposit);
    event eventWithdraw(uint indexed _withdrawID, Withdraw indexed _withdraw);
    event eventBuy(uint indexed _buyID, Buy indexed _buy);

    struct Deposit {
        address _addressContract;
        uint _nftID;
        address _owner;
        uint _price;
        uint _timestamp;
    }

    struct Withdraw {
        address _addressContract;
        uint _nftID;
        address _owner;
        uint _price;
        uint _timestamp;
    }

    struct Buy {
        address _addressContract;
        uint _nftID;
        address _ownerPrevious;
        address _ownerNew;
        uint _price;
        uint _timestamp;
    }

    struct Details {
        address addressContract;
        uint nftID;
        address owner;
        uint price;
    }

    constructor(address _currencyAddress, uint16 _devFeePercent) {
        currency = IERC20(_currencyAddress);
        devFeeAddress = msg.sender;
        devFeePercent = _devFeePercent;
    }
    
    function deposit(address _addressContract, uint _nftID, uint _price) public nonReentrant {
        INFT nft = INFT(_addressContract);
        require(acceptedContracts[_addressContract], 'deposit: this NFT is not accepted by this Marketplace');
        nft.transfer(msg.sender, address(this), _nftID);
        deposited.push(Details(address(nft), _nftID, msg.sender, _price));
        totalDeposit++;
        emit eventDeposit(totalDeposit, Deposit(_addressContract, _nftID, msg.sender, _price, block.timestamp));
    }

    function withdraw(uint _id) public nonReentrant {
        // TODO: check if array exists
        require(deposited[_id].owner == msg.sender, 'withdraw: You are not the owner of this NFT');
        INFT nft = INFT(deposited[_id].addressContract);
        nft.transfer(address(this), msg.sender, deposited[_id].nftID);
        // TODO: remove element from mapping (not possible, try array instead?)
        totalWithdraw++;
        emit eventWithdraw(totalWithdraw, Withdraw(deposited[_id].addressContract, deposited[_id].nftID, deposited[_id].owner, deposited[_id].price, block.timestamp));
        delete deposited[_id];
    }

    function buy(uint _id) public nonReentrant {
        INFT nft = INFT(deposited[_id].addressContract);
        require(nft.getApproved(deposited[_id].nftID) != address(0), 'buy: This NFT is not approved');
        require(currency.allowance(msg.sender, address(this)) >= deposited[_id].price, 'buy: Currency allowance is too low');
        currency.safeTransferFrom(msg.sender, address(this), deposited[_id].price);
        currency.safeTransfer(deposited[_id].owner, deposited[_id].price * (10000 - devFeePercent) / 10000);
        currency.safeTransfer(devFeeAddress, deposited[_id].price * devFeePercent / 10000);
        nft.transfer(address(this), msg.sender, deposited[_id].nftID);
        totalBuy++;
        emit eventBuy(totalBuy, Buy(deposited[_id].addressContract, deposited[_id].nftID, deposited[_id].owner, msg.sender, deposited[_id].price, block.timestamp));
        delete deposited[_id];
    }

    function addAcceptedContract(address _addressContract) public onlyOwner {
        acceptedContracts[_addressContract] = true;
    }

    function setDevFeeAddress(address _devFeeAddress) public onlyOwner {
        devFeeAddress = _devFeeAddress;
    }
}
