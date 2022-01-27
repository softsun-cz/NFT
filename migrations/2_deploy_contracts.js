const NFT = artifacts.require('NFT');
const Marketplace = artifacts.require('Marketplace');

module.exports = async function(deployer) {
 const tokenName = 'Piggy';
 const tokenSymbol = 'PIG';
 const productAddress = '0x0000000000000000000000000000000000000000';
 //var nft = NFT.at('0x0000000000000000000000000000000000000000');

 // NFT:
 //await deployer.deploy(NFT, tokenName, tokenSymbol, productAddress);
 //var nft = await NFT.deployed();

 // MARKETPLACE:
 await deployer.deploy(Marketplace);
 const marketplace = await Marketplace.deployed();
 //marketplace.addAcceptedNFT(nft.address);
};
