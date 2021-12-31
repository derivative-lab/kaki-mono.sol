import { contractAddress, getSigner } from '~/utils/contract';
import { upgrade } from '~/utils/upgrader';
import { CaptainClaim__factory } from '~/typechain';
import { upgrades } from 'hardhat';


(async () => {
  // await upgrade(`captain/CaptainClaim.sol`,'0x54AB58b890118479663810df23a556dA42A497f3', CaptainClaim__factory, false)


  const signer = await getSigner();

  const factory = new CaptainClaim__factory(signer);

  const instance = await upgrades.upgradeProxy('0x54AB58b890118479663810df23a556dA42A497f3',factory);


  console.log(instance.address);

})();