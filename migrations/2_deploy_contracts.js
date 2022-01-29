const NFT = artifacts.require('NFT');
const ProductToken = artifacts.require('ProductToken');
const Factory = artifacts.require('Factory');
const Marketplace = artifacts.require('Marketplace');

module.exports = async function(deployer) {
 const nftName = 'Piggy';
 const nftSymbol = 'PIG';
 const productTokenName = 'Truffle';
 const productTokenSymbol = 'TRF';
 const marketplaceCurrencyAddress = '0xF42a4429F107bD120C5E42E069FDad0AC625F615'; // XUSD
 const marketplaceDevFeePercent = '100'; // 1%
 const factoryInitialCount = 10;
 const factoryInitialPrice = 10000000000000000000;

 // PRODUCT TOKEN:
 await deployer.deploy(ProductToken, productTokenName, productTokenSymbol);
 var productToken = await ProductToken.deployed();
 
 // NFT:
 await deployer.deploy(NFT, nftName, nftSymbol, productToken.address);
 var nft = await NFT.deployed();

 // MARKETPLACE:
 await deployer.deploy(Marketplace, marketplaceCurrencyAddress, marketplaceDevFeePercent);
 const marketplace = await Marketplace.deployed();

 // FACTORY:
 await deployer.deploy(Factory, nft.address, marketplace.address);
 const factory = await Factory.deployed();
 
 console.log('------------');
 console.log(await factory.owner());
 console.log('------------');

 // SETTINGS:
 await productToken.transferOwnership(nft.address);
 await nft.transferOwnership(factory.address);
 await marketplace.addAcceptedContract(nft.address);
 await factory.mintToMarketplace(factoryInitialCount, nftName, factoryInitialPrice);

 // LOG:
 console.log('');
 console.log('=============================================================');
 console.log('| NFT:           ' + nft.address + ' |');
 console.log('| Product token: ' + productToken.address + ' |');
 console.log('| Factory:       ' + factory.address + ' |');
 console.log('| Marketplace:   ' + marketplace.address + ' |');
 console.log('=============================================================');
};
