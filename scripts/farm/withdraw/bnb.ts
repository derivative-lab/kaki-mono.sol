import { farmContract, getSigner } from '~/utils/contract';
import { printEtherResult } from '../../../utils/logutil';

(async () => {
  const farm = await farmContract();
  const signer = await getSigner(0);
  const user = await farm._userInfo(0, signer.address);
  printEtherResult(user);
  const tx = await farm.withdraw(0, user.amount.div(3), { gasLimit: 1000000 });
  console.log(tx.hash)
})();
