import { kakiContract, getSigner } from '~/utils/contract';
import { parseEther } from 'ethers/lib/utils';

(async () => {
  const kaki = await kakiContract();
  const signer = await getSigner(0);

  //const tx = await kaki.mint(signer.address, parseEther('1'));
  const tx = await kaki.mint("0x7430b734205366542B59541bC1201C46E666175c", parseEther('20200'));
  console.log(tx.hash);
})();
