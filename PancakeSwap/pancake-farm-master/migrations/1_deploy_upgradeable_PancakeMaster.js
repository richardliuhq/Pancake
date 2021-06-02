
const CakeToken = artifacts.require('CakeToken');
const BnbStaking = artifacts.require('BnbStaking');
const SyrupBar = artifacts.require('SyrupBar');
const MasterChef = artifacts.require('MasterChef');
const WBNB = artifacts.require('libs/WBNB');
const SousChef = artifacts.require('SousChef');
//const BnbStaking = artifacts.require('BnbStaking');

module.exports = async function (deployer) {
  //deployer.deploy(PancakeFactory,"0x489489E5B1Ae50BE1c4B5ADbD9ecB6FF586F99D7");
  const owner= '0x489489E5B1Ae50BE1c4B5ADbD9ecB6FF586F99D7';

  await deployer.deploy(CakeToken);
  const cake= await CakeToken.deployed();

  await deployer.deploy(WBNB);
  const wBNB = await WBNB.deployed();


  await deployer.deploy(SyrupBar, cake.address,);
  const syrup = await SyrupBar.deployed();

 //Get the latest block from the bsc scan web site. suc as the latest block is "9332716" when I prepare this
  await deployer.deploy(MasterChef, cake.address,syrup.address, owner, '40000000000000000000', '9332716');
  const chef = await MasterChef.deployed();


  //debug only=========================================================
  await cake.mint(owner,'99999999999999999999999');
 
  await cake.transferOwnership(chef.address);
  await syrup.transferOwnership(chef.address);


  await deployer.deploy(BnbStaking, 
      wBNB.address,
      cake.address,
      1000,
      10,
      1010,
      owner,
      wBNB.address
    );
   const bnbChef = await MasterChef.deployed();

   await deployer.deploy(SousChef, syrup.address, '40', '300', '400');
   const sousChef = await SousChef.deployed();


};
