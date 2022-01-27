// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Marketplace is Ownable {
    mapping (address => bool) public acceptedNFT;
    
    function addAcceptedNFT(address _addressNFT) public onlyOwner {
        acceptedNFT[_addressNFT] = true;
    }
}