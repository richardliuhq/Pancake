const PancakeRouter01 = artifacts.require("PancakeRouter01");
const PancakeRouter = artifacts.require("PancakeRouter");




module.exports = async function (deployer) {
 const owner= '0x489489E5B1Ae50BE1c4B5ADbD9ecB6FF586F99D7';

  // following pair of tokens address get from "pancake-farm-master" deployment
  const token0='0x73523F93ac317A4C4F052a7096aA7c8978E4F893';
  const token1='0x403738632d7344E32EEd2c26b228F16eEdda84A4';
  const wbmb='0x403738632d7344E32EEd2c26b228F16eEdda84A4';

  //factory address get from "\pancake-swap-core-master" deployment
  const factory ='0x1A9051a0951C76aF866d5a631a796590abaC7b33';

  await deployer.deploy(PancakeRouter01,factory, wbmb);
  const router01= await PancakeRouter01.deployed();

  await deployer.deploy(PancakeRouter,factory, wbmb);
  const router= await PancakeRouter.deployed();

};  
