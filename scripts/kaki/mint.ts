import { kakiContract, getSigner } from '~/utils/contract';
import { parseEther } from 'ethers/lib/utils';

(async () => {
  const kaki = await kakiContract();
  const signer = await getSigner(0);

  const tx = await kaki.mint(signer.address, parseEther('1'));
  console.log(tx.hash);
})();
