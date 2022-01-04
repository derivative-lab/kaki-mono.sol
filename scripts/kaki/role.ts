import { kakiContract, getSigner } from '~/utils/contract';

(async () => {
  const kaki = await kakiContract();
  const mintRole = await kaki.MINTER();
  const signer0 = await getSigner(0);
  const tx = await kaki.grantRole(mintRole, signer0.address);
  console.log(tx.hash);
})();
