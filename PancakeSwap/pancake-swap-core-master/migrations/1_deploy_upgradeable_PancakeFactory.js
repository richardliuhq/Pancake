const PancakeFactory = artifacts.require("PancakeFactory");

module.exports = async function (deployer) {
 const owner= '0x489489E5B1Ae50BE1c4B5ADbD9ecB6FF586F99D7';

  // following pair of tokens address get from "pancake-farm-master" deployment. such as token0 (CAKE) and Token1 (WBNB)
  const token0='0x73523F93ac317A4C4F052a7096aA7c8978E4F893';
  const token1='0x403738632d7344E32EEd2c26b228F16eEdda84A4';

  await deployer.deploy(PancakeFactory,owner);
  const factory= await PancakeFactory.deployed();

  await factory.createPair(token0, token1);
  await factory.setFeeTo(owner);

};  
