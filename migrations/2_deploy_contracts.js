const ProductToken = artifacts.require('ProductToken');
const NFT = artifacts.require('NFT');
const Marketplace = artifacts.require('Marketplace');

module.exports = async function(deployer) {
 const nftName = 'Piggy';
 const nftSymbol = 'PIG';
 const productTokenName = 'Truffle';
 const productTokenSymbol = 'TRF';
 //const productToken = ProductToken.at('0xfAAe281b721c6cE8D0428a80445Be60669C4f71F');
 //const nft = NFT.at('0x0000000000000000000000000000000000000000');

 // PRODUCT TOKEN:
 await deployer.deploy(ProductToken, productTokenName, productTokenSymbol);
 const productToken = await NFT.deployed();

 // NFT:
 await deployer.deploy(NFT, nftName, nftSymbol, productToken.address);
 const nft = await NFT.deployed();

 // MARKETPLACE:
 await deployer.deploy(Marketplace);
 const marketplace = await Marketplace.deployed();
 marketplace.addAcceptedNFT(nft.address);
};
