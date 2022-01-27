// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFT is ERC721, Ownable {
    string public tokenName;
    string public tokenSymbol;
    uint public tokenCount;
    address public productAddress;
    mapping (uint => Details) private tokenDetails;

    struct Details {
        string name;
        bool sex;
        uint bodyID;
        uint eyesID;
        uint noseID;
        uint mouthID;
        uint earsID;
        uint level;
        uint created;
    }

    constructor(string memory _tokenName, string memory _tokenSymbol, address _productAddress) ERC721(_tokenName, _tokenSymbol) {
        tokenName = _tokenName;
        tokenSymbol = _tokenSymbol;
        productAddress = _productAddress;
        for (uint16 i = 0; i < 1000; i++) mint(string(abi.encodePacked(tokenName, ' ', Strings.toString(i))));
    }

    function getTokenDetails(uint tokenID) public view returns (Details memory) {
        return tokenDetails[tokenID];
    }

    function setTokenName(uint tokenID, string memory _newName) public {
        require(ownerOf(tokenID) == msg.sender, 'setTokenName: You are not the owner of this token');
        require(utfStrLen(_newName) <= 16, 'setTokenName: Name is too long. Maximum: 16 characters');
        require(charMatch(_newName), 'setTokenName: Name can contain only a-z, A-Z, 0-9, space and dot');
        tokenDetails[tokenID].name = _newName;
    }

    function mint(string memory _name) public onlyOwner {
        _safeMint(msg.sender, tokenCount);
        tokenDetails[tokenCount] = Details(
            _name,
            getRandomNumber(2) == 1 ? true : false,
            getRandomNumber(3),
            getRandomNumber(5),
            getRandomNumber(5),
            getRandomNumber(5),
            getRandomNumber(5),
            1,
            block.timestamp
        );
        tokenCount++;
    }

    function getRandomNumber(uint _num) private view returns (uint) {
        return uint(uint(keccak256(abi.encodePacked(block.timestamp, block.difficulty))) % _num);
    }
    
    function utfStrLen(string memory str) pure internal returns (uint) {
        uint length = 0;
        uint i = 0;
        bytes memory string_rep = bytes(str);
        while (i < string_rep.length) {
            if (string_rep[i] >> 7 == 0) i++;
            else if (string_rep[i] >> 5 == bytes1(uint8(0x6))) i += 2;
            else if (string_rep[i] >> 4 == bytes1(uint8(0xE))) i += 3;
            else if (string_rep[i] >> 3 == bytes1(uint8(0x1E))) i += 4;
            else i += 1;
            length++;
        }
        return length;
    }
    
    function charMatch(string memory str) public pure returns (bool) { // ASCII table: https://www.asciitable.com/
        bytes memory b = bytes(str);
        for (uint i; i < b.length; i++) {
            bytes1 char = b[i];
            if (!(char >= 0x61 && char <= 0x7A) && // a-z
                !(char >= 0x41 && char <= 0x5A) && // A-Z
                !(char >= 0x30 && char <= 0x39) && // 0-9
                !(char == 0x20) && // Space
                !(char == 0x2E) // Dot
            ) return false;
        }
        return true;
    }
}
