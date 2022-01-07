import { farmContract } from '~/utils/contract';
import { parseEther } from 'ethers/lib/utils';


(async () => {

  const farm = await farmContract();
  const v = parseEther('0.001');
  const ov = { value: v, gasLimit: 1000000 }
  const tx = await farm.deposit(0, v, ov);
  console.log(tx.hash)


})();
