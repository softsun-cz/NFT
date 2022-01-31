const Marketplace = artifacts.require('Marketplace');
const NFT = artifacts.require('NFT');
const Sale = artifacts.require('Sale');
const TokenProduct = artifacts.require('TokenProduct');
const TokenUpgrade = artifacts.require('TokenUpgrade');
const TokenFactory = artifacts.require('TokenFactory');

module.exports = async function(deployer) {
 const devFeeAddress = '0x650E5c6071f31065d7d5Bf6CaD5173819cA72c41';
 const burnAddress = '0x000000000000000000000000000000000000dEaD';
 const nftName = 'Animals.town';
 const nftSymbol = 'ATOWN';
 const nftDevFeePercent = '500'; // 5%
 const tokenFactoryName = 'Animals.town - Love';
 const tokenFactorySymbol = 'LOVE';
 const tokenProductName = 'Animals.town - Gold';
 const tokenProductSymbol = 'GOLD';
 const tokenUpgradeName = 'Animals.town - Upgrade';
 const tokenUpgradeSymbol = 'UPG';
 const marketplaceCurrencyAddress = '0xF42a4429F107bD120C5E42E069FDad0AC625F615'; // XUSD
 const marketplaceDevFeePercent = '100'; // 1%
 const saleCurrencyAddress = '0xF42a4429F107bD120C5E42E069FDad0AC625F615'; // XUSD
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
/*
 // SALE:
 await deployer.deploy(Sale, saleCurrencyAddress);
 var sale = await Sale.deployed();
*/
 // TOKEN UPGRADE:
 await deployer.deploy(TokenUpgrade, tokenUpgradeName, tokenUpgradeSymbol);
 var tokenUpgrade = await TokenUpgrade.deployed();

 // TOKEN FACTORY:
 await deployer.deploy(TokenFactory, tokenFactoryName, tokenFactorySymbol);
 var tokenFactory = await TokenFactory.deployed();

 // TOKEN PRODUCT:
 await deployer.deploy(TokenProduct, tokenProductName, tokenProductSymbol);
 var tokenProduct = await TokenProduct.deployed();

 // MARKETPLACE:
 await deployer.deploy(Marketplace, marketplaceCurrencyAddress, marketplaceDevFeePercent);
 var marketplace = await Marketplace.deployed();

 // NFT:
 await deployer.deploy(NFT, nftName, nftSymbol, nftDevFeePercent, devFeeAddress, burnAddress, marketplace.address, tokenFactory.address, tokenProduct.address, tokenUpgrade.address);
 var nft = await NFT.deployed();

 // SETTINGS:
 await marketplace.addAcceptedContract(nft.address);
 await tokenProduct.transferOwnership(nft.address);
 /*
 await tokenUpgrade.transferOwnership(sale.address);
 await tokenFactory.transferOwnership(sale.address);
 await sale.addToken(tokenFactory.address, saleTokenFactoryInitialPrice, saleTokenFactoryIncreaseEvery, saleTokenFactoryMultiplier);
 await sale.addToken(tokenUpgrade.address, saleTokenUpgradeInitialPrice, saleTokenUpgradeIncreaseEvery, saleTokenUpgradeMultiplier);
 
 // SALE - TEST
 const maxint = '115792089237316195423570985008687907853269984665640564039457584007913129639935';
 var xusd = await TokenProduct.at('0xF42a4429F107bD120C5E42E069FDad0AC625F615');
 await xusd.approve(sale.address, maxint);
*/
 // NFT - TEST
 tokenUpgrade.mint('10000000000000000000000'); // 10 000 UPG
 tokenFactory.mint('10000000000000000000000'); // 10 000 LOVE

 // LOG:
 console.log('');
 console.log('=============================================================');
 console.log('| NFT:           ' + nft.address + ' |');
 console.log('| Token Factory: ' + tokenFactory.address + ' |');
 console.log('| Token Product: ' + tokenProduct.address + ' |');
 console.log('| Token Upgrade: ' + tokenUpgrade.address + ' |');
 //console.log('| Sale:          ' + sale.address + ' |');
 console.log('| Marketplace:   ' + marketplace.address + ' |');
 console.log('=============================================================');
};
