const Toklen = artifacts.require("Token");

module.exports = async function(deployer) {
  await deployer.deploy(Token, "Animal Farm Token", "ANF");
  let tokenInstance = await Token.deployed();
  await tokenInstance.mint(1, true);
  let animal = await tokenInstance.getTokenDetails(0);
  console.log(animal);
};
