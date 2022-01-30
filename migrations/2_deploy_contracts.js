const Factory = artifacts.require('Factory');
const Marketplace = artifacts.require('Marketplace');
const NFT = artifacts.require('NFT');
const Sale = artifacts.require('Sale');
const TokenProduct = artifacts.require('TokenProduct');
const TokenUpgrade = artifacts.require('TokenUpgrade');
const TokenFactory = artifacts.require('TokenFactory');

module.exports = async function(deployer) {
 const nftName = 'Piggy';
 const nftSymbol = 'PIG';
 const tokenFactoryName = 'Love';
 const tokenFactorySymbol = 'LOVE';
 const tokenProductName = 'Gold';
 const tokenProductSymbol = 'GOLD';
 const tokenUpgradeName = 'Upgrade';
 const tokenUpgradeSymbol = 'UPG';
 const marketplaceCurrencyAddress = '0xF42a4429F107bD120C5E42E069FDad0AC625F615'; // XUSD
 const marketplaceDevFeePercent = '100'; // 1%
 const saleCurrencyAddress = '0xF42a4429F107bD120C5E42E069FDad0AC625F615'; // XUSD
 const factoryDevFeePercent = '5';
 const factoryBreedPrice = '10000000000000000000'; // 10 UPG
 const factoryInitialCount = '500';
 const factoryInitialPrice = '10000000000000000000';
 const saleTokenUpgradeInitialPrice = '1000000000000000000'; // 1 XUSD / UPG
 const saleTokenUpgradeIncreaseEvery = '100000000000000000000'; // 100 UPG
 const saleTokenUpgradeMultiplier = '1000'; // 10%
 const saleTokenFactoryInitialPrice = '2000000000000000000'; // 2 XUSD / tokenUpgrade
 const saleTokenFactoryIncreaseEvery = '100000000000000000000'; // 100 UPG
 const saleTokenFactoryMultiplier = '100'; // 1%
 //var tokenProduct = await TokenProduct.at('');
 //var tokenFactory = await TokenFactory.at('');
 //var tokenUpgrade = await TokenUpgrade.at('');
 //var nft = await NFT.at('');
 //var marketplace = await Marketplace.at('');
 //var factory = await Marketplace.at('');

 // SALE:
 await deployer.deploy(Sale, saleCurrencyAddress);
 var sale = await Sale.deployed();

 // TOKEN UPGRADE:
 await deployer.deploy(TokenUpgrade, tokenUpgradeName, tokenUpgradeSymbol);
 var tokenUpgrade = await TokenUpgrade.deployed();

 // TOKEN FACTORY:
 await deployer.deploy(TokenFactory, tokenFactoryName, tokenFactorySymbol);
 var tokenFactory = await TokenFactory.deployed();
/*
 // TOKEN PRODUCT:
 await deployer.deploy(TokenProduct, tokenProductName, tokenProductSymbol);
 var tokenProduct = await TokenProduct.deployed();

 // NFT:
 await deployer.deploy(NFT, nftName, nftSymbol, tokenProduct.address);
 var nft = await NFT.deployed();

 // MARKETPLACE:
 await deployer.deploy(Marketplace, marketplaceCurrencyAddress, marketplaceDevFeePercent);
 var marketplace = await Marketplace.deployed();

 // FACTORY:
 await deployer.deploy(Factory, nft.address, marketplace.address, tokenFactory.address, factoryBreedPrice, factoryDevFeePercent);
 var factory = await Factory.deployed();

 // SETTINGS:
 await tokenProduct.transferOwnership(nft.address);
 await nft.transferOwnership(factory.address);
 await marketplace.addAcceptedContract(nft.address);
*/
 await sale.addToken(tokenFactory.address, saleTokenFactoryInitialPrice, saleTokenFactoryIncreaseEvery, saleTokenFactoryMultiplier);
 await sale.addToken(tokenUpgrade.address, saleTokenUpgradeInitialPrice, saleTokenUpgradeIncreaseEvery, saleTokenUpgradeMultiplier);
 await tokenUpgrade.transferOwnership(sale.address);
 await tokenFactory.transferOwnership(sale.address);
 //await factory.mintToMarketplace(factoryInitialCount, nftName, factoryInitialPrice);
/*
 // SALE - TEST
 const maxint = '115792089237316195423570985008687907853269984665640564039457584007913129639935';
 var xusd = await TokenProduct.at('0xF42a4429F107bD120C5E42E069FDad0AC625F615');
 await xusd.approve(sale.address, maxint);
*/
// LOG:
 console.log('');
 console.log('=============================================================');
 //console.log('| NFT:           ' + nft.address + ' |');
 console.log('| Token Factory: ' + tokenFactory.address + ' |');
 //console.log('| Token Product: ' + tokenProduct.address + ' |');
 console.log('| Token Upgrade: ' + tokenUpgrade.address + ' |');
 console.log('| Sale:          ' + sale.address + ' |');
 //console.log('| Factory:       ' + factory.address + ' |');
 //console.log('| Marketplace:   ' + marketplace.address + ' |');
 console.log('=============================================================');
};
