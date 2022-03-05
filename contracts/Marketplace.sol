// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "hardhat/console.sol";

import "./libs/INFT.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Marketplace is Ownable, ReentrancyGuard, IERC721Receiver {
  using SafeERC20 for IERC20;
  IERC20 currency;
  address devFeeAddress;
  uint16 devFeePercent;
  uint256 totalDeposits;
  uint256 totalDeposited;
  uint256 totalWithdraws;
  uint256 totalBuys;
  mapping(address => bool) public acceptedContracts;
  mapping(uint256 => Details) public deposited;
  event eventDeposit(uint256 indexed _depositID, Deposit indexed _deposit);
  event eventWithdraw(uint256 indexed _withdrawID, Withdraw indexed _withdraw);
  event eventBuy(uint256 indexed _buyID, Buy indexed _buy);

  struct Deposit {
    address _addressContract;
    uint256 _nftID;
    address _owner;
    uint256 _price;
    uint256 _timestamp;
  }

  struct Withdraw {
    address _addressContract;
    uint256 _nftID;
    address _owner;
    uint256 _price;
    uint256 _timestamp;
  }

  struct Buy {
    address _addressContract;
    uint256 _nftID;
    address _ownerPrevious;
    address _ownerNew;
    uint256 _price;
    uint256 _timestamp;
  }

  struct Details {
    bool exists;
    address addressContract;
    uint256 nftID;
    address owner;
    uint256 price;
  }

  constructor(address _currencyAddress, uint16 _devFeePercent) {
    currency = IERC20(_currencyAddress);
    devFeeAddress = msg.sender;
    devFeePercent = _devFeePercent;
  }

  function deposit(
    address _addressContract,
    uint256 _nftID,
    uint256 _price
  ) public nonReentrant {
    INFT nft = INFT(_addressContract);
    require(
      acceptedContracts[_addressContract],
      "deposit: this NFT is not accepted by this Marketplace"
    );
    require(
      nft.ownerOf(_nftID) == msg.sender,
      "deposit: You are not the owner of this NFT"
    );
    nft.transfer(msg.sender, address(this), _nftID);
    deposited[totalDeposits] = Details(
      true,
      address(nft),
      _nftID,
      msg.sender,
      _price
    );
    totalDeposits++;
    totalDeposited++;
    emit eventDeposit(
      totalDeposits,
      Deposit(_addressContract, _nftID, msg.sender, _price, block.timestamp)
    );
  }

  function withdraw(uint256 _id) public nonReentrant {
    require(deposited[_id].exists, "withdraw: Item ID not found");
    require(
      deposited[_id].owner == msg.sender,
      "withdraw: You are not the owner of this NFT"
    );
    INFT nft = INFT(deposited[_id].addressContract);
    nft.transfer(address(this), msg.sender, deposited[_id].nftID);
    delete deposited[_id];
    totalWithdraws++;
    totalDeposited--;
    emit eventWithdraw(
      totalWithdraws,
      Withdraw(
        deposited[_id].addressContract,
        deposited[_id].nftID,
        deposited[_id].owner,
        deposited[_id].price,
        block.timestamp
      )
    );
  }

  function buy(uint256 _id) public nonReentrant {
    INFT nft = INFT(deposited[_id].addressContract);
    require(
      nft.getApproved(deposited[_id].nftID) != address(0),
      "buy: This NFT is not approved"
    );
    require(
      currency.allowance(msg.sender, address(this)) >= deposited[_id].price,
      "buy: Currency allowance is too low"
    );
    currency.safeTransferFrom(msg.sender, address(this), deposited[_id].price);
    currency.safeTransfer(
      deposited[_id].owner,
      (deposited[_id].price * (10000 - devFeePercent)) / 10000
    );
    currency.safeTransfer(
      devFeeAddress,
      (deposited[_id].price * devFeePercent) / 10000
    );
    nft.transfer(address(this), msg.sender, deposited[_id].nftID);
    totalBuys++;
    totalDeposited--;
    emit eventBuy(
      totalBuys,
      Buy(
        deposited[_id].addressContract,
        deposited[_id].nftID,
        deposited[_id].owner,
        msg.sender,
        deposited[_id].price,
        block.timestamp
      )
    );
    delete deposited[_id];
  }

  function addAcceptedContract(address _addressContract) public onlyOwner {
    acceptedContracts[_addressContract] = true;
  }

  function setDevFeeAddress(address _devFeeAddress) public onlyOwner {
    devFeeAddress = _devFeeAddress;
  }

  function onERC721Received(
    address operator,
    address from,
    uint256 tokenId,
    bytes calldata data
  ) public pure override returns (bytes4) {
    return IERC721Receiver.onERC721Received.selector;
  }
}
