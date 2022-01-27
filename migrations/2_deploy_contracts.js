const NFT = artifacts.require('NFT');
const Marketplace = artifacts.require('MarketPlace');

module.exports = async function(deployer) {
 const tokenName = 'Piggy';
 const tokenSymbol = 'PIG';
 const productAddress = '0x0000000000000000000000000000000000000000';

 await deployer.deploy(NFT, tokenName, tokenSymbol, productAddress);
 const nft = await NFT.deployed();

 await deployer.deploy(Marketplace);
 const marketplace = await Marketplace.deployed();
 marketplace.addAcceptedNFT(nft.address);
};
