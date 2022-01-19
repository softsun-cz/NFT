pragma solidity 0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Token is ERC721, Ownable {
 // Part 1: https://www.youtube.com/watch?v=_VVqa7zWSxA
 // Part 2: https://www.youtube.com/watch?v=y519kGkAQd8
 // TODO: Add owner address (MasterChef) + require
 // TODO: Create MasterChef smart contract

 // Pig      -> Truffle   -> Truffle chocolate
 // Cow      -> Cow milk  -> Cheese
 // Hen      -> Egg       -> Pie
 // Sheep    -> Wool      -> Clothes
 // Goat     -> Goat milk -> Goat cheese
 // Horse    -> Horsehair -> Bed
 // Bee      -> Honey     -> Honey cake
 // Goldfish -> Wishes    -> Happy life

 string[] TokenKind = ['Pig', 'Cow', 'Hen', 'Sheep', 'Goat', 'Horse', 'Bee', 'Goldfish'];
 string[] ProductKind = ['Truffle', 'Cow milk', 'Egg', 'Wool', 'Goat cheese', 'Horsehair', 'Honey', 'Wishes'];

 struct TokenProperties {
  TokenKind kind;
  string name;
  ProductKind product;
  string productTokenAddress;
  string parentMaleAddress;
  string parentFemaleAddress;
 }

 struct Details {
  uint16 typeID;
  bool sex;
  uint8 level;
  uint256 created;
 }

 uint256 nextID = 0;
 mapping (uint256 => Details) private _tokenDetails;

 constructor(string memory name, string memory symbol) ERC721(name, symbol) {

 }

 function getTokenDetails(uint256 tokenID) public view returns (Details memory) {
  return _tokenDetails[tokenID];
 }

 function setTokenName(string name) {
  // TODO: pokud nastavuje owner tokenu, pak zmenit jmeno (musi se nejak omezit pocet pismen a znaky)
 }

 function mint(uint16 typeID, bool sex) {
  _safeMint(msg.sender, nextID);
  _tokenDetails[nextID] = Details(typeID, sex, 1, block.timestamp);
  nextID++;
 }
}
