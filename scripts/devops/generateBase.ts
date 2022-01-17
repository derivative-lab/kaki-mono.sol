import {Kaki__factory} from '~/typechain';
import { getSigner } from '~/utils/contract';
import { upgrades } from 'hardhat';

(async ()=>{
  const signer = await getSigner(0);
  const factory = new Kaki__factory(signer);

  const instance = await upgrades.deployProxy(factory)
  console.log(`kaki deployed to: ${instance.address}`)

})();
