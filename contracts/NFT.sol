// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFT is ERC721, Ownable {
    string public tokenName;
    uint public tokenCount;
    address public productAddress;
    mapping (uint => Detail) private _tokenDetails;

    struct Detail {
        string name;
        bool sex;
        uint8 bodyID;
        uint8 eyesID;
        uint8 noseID;
        uint8 mouthID;
        uint8 earsID;
        uint level;
        uint created;
    }

    constructor(string memory _tokenName, string memory _tokenSymbol, address _productAddress) ERC721(_tokenName, _tokenSymbol) {
        tokenName = _tokenName;
        tokenSymbol = _tokenSymbol;
        productAddress = _productAddress;
        for (uint10 i = 0; i < 1000; i++) mint(_tokenName + string(i));
    }

    function getTokenDetails(uint tokenID) public view returns (Details memory) {
        return _tokenDetails[tokenID];
    }

    function setTokenName(uint tokenID, string _newName) public {
        // TODO: omezit pocet pismen a znaky
    }

    function mint(string memory _name) public onlyOwner {
        _safeMint(msg.sender, tokenCount);
        _tokenDetails[tokenCount] = Details(
            _name,
            getRandomBool(_sex),
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
        return uint(uint(keccak256(block.timestamp, block.difficulty))%_num);
    }
    function getRandomBool() private view returns (bool) {
        return bool(uint(keccak256(block.timestamp, block.difficulty))%2 == 1 ? true : false);
    }
}
