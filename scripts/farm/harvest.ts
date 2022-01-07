import { farmContract } from '~/utils/contract';
import { parseEther } from 'ethers/lib/utils';


(async () => {

  const farm = await farmContract();
  const tx = await farm.harvest(0);
  console.log(tx.hash)
})();
