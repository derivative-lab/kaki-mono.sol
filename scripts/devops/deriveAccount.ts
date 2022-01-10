import { deriveAccount } from '../../utils/generateAddr';


(async () => {
  const mnemonic = process.env.MNEMONIC;
  const account = deriveAccount(mnemonic, 0);
  console.log(account);
})();
