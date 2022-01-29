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
    Details[] tokens;
    uint buyTotal;
    event eventBuy(address indexed tokenAddress, uint indexed amountCurrency, uint indexed amountOur);
    event eventAddToken(uint indexed id, Details indexed details);

    constructor(address _currencyAddress) {
        currency = IERC20(_currencyAddress);
        devAddress = msg.sender;
    }

    struct Details {
        address tokenAddress;
        uint initialPrice;
        uint increaseEvery;
        uint multiplier;
        uint buyAmount;
        uint buyCount;
    }

    function buyToken(uint _id, uint _amount) public nonReentrant {
        require(_id <= tokens.length, 'buy: Token not found');
        require(currency.allowance(msg.sender, address(this)) >= _amount, 'buy: Currency allowance is too low');

        uint buy = tokens[_id].buyAmount;
        uint price = tokens[_id].initialPrice;
        uint incEvery = tokens[_id].increaseEvery;
        uint multiplier = tokens[_id].multiplier;
        uint amountOur;
        uint segmentNum = buy / incEvery;
        uint priceActual = price;
        for (uint i = 1; i < segmentNum; i++) {
            priceActual += priceActual * multiplier / 10000;
        }
        uint actualAmount = _amount;
        uint segmentCount = incEvery - (buy % incEvery);
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
        IERC20Mint token = IERC20Mint(tokens[_id].tokenAddress);
        token.mint(amountOur);
        token.safeTransfer(msg.sender, amountOur);
        tokens[_id].buyAmount += amountOur;
        tokens[_id].buyCount++;
        buyTotal++;
        emit eventBuy(tokens[_id].tokenAddress, _amount, amountOur);
    }

    function addToken(address _tokenAddress, uint _initialPrice, uint _increaseEvery, uint _multiplier) public onlyOwner {
        Details memory details = Details(_tokenAddress, _initialPrice, _increaseEvery, _multiplier, 0, 0);
        tokens.push(details);
        emit eventAddToken(tokens.length - 1, details);
    }

    function setDevAddress(address _devAddress) public onlyOwner {
        devAddress = _devAddress;
    }
}
