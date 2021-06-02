const VaultFlipToFlip = artifacts.require("./InnovationUpstream/VaultFlipToFlip");
const ZapBSC = artifacts.require("./InnovationUpstream/ZapBSC");


module.exports =async function (deployer) {

  //Update pointer to PancakeAwap: IPancakeRouter02(0x171877B464e31df7d803149c13AE8eEE71b219f6);
/*  await deployer.deploy(ZapBSC);
  const zapBSC = await ZapBSC.deployed();
  await zapBSC.initialize();*/

  await deployer.deploy(VaultFlipToFlip);
  const vaultFlipToFlip=await VaultFlipToFlip.deployed();
};
