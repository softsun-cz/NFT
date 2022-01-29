// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import './libs/IERC20Mint.sol';
import './libs/SafeERC20Mint.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/security/ReentrancyGuard.sol';

contract Sale is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;
    using SafeERC20Mint for IERC20Mint;
    IERC20 currency;
    address devAddress;
    mapping (address => Details) public tokens;
    event eventBuy(address indexed tokenAddress, uint indexed amountCurrency, uint indexed amountOur);
    event eventAddToken(address indexed tokenAddress, Details indexed details);

    constructor(address _currencyAddress) {
        currency = IERC20(_currencyAddress);
        devAddress = msg.sender;
    }

    struct Details {
        uint initialPrice;
        uint increaseEvery;
        uint multiplier;
        uint sold;
    }

    function buy(address _tokenAddress, uint _amount) public nonReentrant {
        require(tokens[_tokenAddress].initialPrice > 0, 'buy: Token not found'); // TODO: check if token exists more elegantly
        require(currency.allowance(msg.sender, address(this)) >= _amount, 'buy: Currency allowance is too low');

        uint sold = tokens[_tokenAddress].sold;
        uint price = tokens[_tokenAddress].initialPrice;
        uint incEvery = tokens[_tokenAddress].increaseEvery;
        uint multiplier = tokens[_tokenAddress].multiplier;
        uint amountOur;
        uint segmentNum = sold/incEvery;
        uint priceActual = price;
        for (uint i = 1; i < segmentNum; i++) {
            priceActual = priceActual + priceActual * multiplier / 10000;
        }
        uint actualAmount = _amount;
        uint segmentCount = incEvery - (sold % incEvery);
        while (actualAmount > 0) {
            uint segmentCost = segmentCount * priceActual;
            if (actualAmount < segmentCost) {
                amountOur += actualAmount / priceActual;
                actualAmount = 0;
            } else {
                amountOur += segmentCount;
                actualAmount -= segmentCost;
                segmentCount = incEvery;
                priceActual = priceActual + priceActual * multiplier / 10000;
            }
        }

        currency.safeTransferFrom(msg.sender, address(this), _amount);
        currency.safeTransfer(devAddress, _amount);
        IERC20Mint token = IERC20Mint(_tokenAddress);
        token.mint(amountOur);
        token.safeTransfer(msg.sender, amountOur);
        tokens[_tokenAddress].sold += amountOur;
        emit eventBuy(_tokenAddress, _amount, amountOur);
    }

    function addToken(address _tokenAddress, uint _initialPrice, uint _increaseEvery, uint _multiplier) public onlyOwner {
        // TODO: require(tokens[_tokenAddress] == address(0x0), 'addToken: Token not found');
        Details memory details = Details(_initialPrice, _increaseEvery, _multiplier, 0);
        tokens[_tokenAddress] = details;
        emit eventAddToken(_tokenAddress, details);
    }

    function setDevAddress(address _devAddress) public onlyOwner {
        devAddress = _devAddress;
    }
}
