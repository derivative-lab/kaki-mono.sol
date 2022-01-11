import { contractAddress, getSigner } from '~/utils/contract';
import { upgrade } from '~/utils/upgrader';
import { CaptainClaim__factory, ClaimLock } from '~/typechain';
import { upgrades } from 'hardhat';


(async () => {
  await upgrade(`claimLock/ClaimLock.sol`,contractAddress.claimLock)


  // const signer = await getSigner();

  // const factory = new CaptainClaim__factory(signer);

  // const instance = await upgrades.upgradeProxy('0x925F3d41fe2Ae5213338Ed1fc85598b3e0dB8F6c',factory);


  // console.log(instance.address);

})();