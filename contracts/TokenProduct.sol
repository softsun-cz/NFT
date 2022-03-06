// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TokenProduct is ERC20, Ownable {
  constructor(string memory _name, string memory _symbol) ERC20(_name, _symbol) {}

  function mint(uint256 _amount) external onlyOwner {
    _mint(msg.sender, _amount);
  }
}
