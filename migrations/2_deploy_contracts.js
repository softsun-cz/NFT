const ProductToken = artifacts.require('ProductToken');
const NFT = artifacts.require('NFT');
const Marketplace = artifacts.require('Marketplace');

module.exports = async function(deployer) {
 const nftName = 'Piggy';
 const nftSymbol = 'PIG';
 const productTokenName = 'Truffle';
 const productTokenSymbol = 'TRF';
 //const productToken = ProductToken.at('0xfDe1F5E955C83B2f076D4ca546b72E5e575F1093');
 //const nft = NFT.at('0x0000000000000000000000000000000000000000');

 // PRODUCT TOKEN:
 await deployer.deploy(ProductToken, productTokenName, productTokenSymbol);
 const productToken = await ProductToken.deployed();

 // NFT:
 await deployer.deploy(NFT, nftName, nftSymbol, productToken.address);
 const nft = await NFT.deployed();

 // MARKETPLACE:
 await deployer.deploy(Marketplace);
 const marketplace = await Marketplace.deployed();
 marketplace.addAcceptedNFT(nft.address);
};
