

import { zeroAddress } from 'ethereumjs-util';
import { farmContract } from '~/utils/contract';


(async () => {

  const farm = await farmContract();

  // https://github.com/alpaca-finance/bsc-alpaca-contract/blob/main/.testnet.json

  const tx = await farm.addPool(100, zeroAddress(), 330 * 10000, '0xf9d32C5E10Dd51511894b360e6bD39D7573450F9','0xf9d32c5e10dd51511894b360e6bd39d7573450f9','0xac2fefDaF83285EA016BE3f5f1fb039eb800F43D',1,true,"BNB-pool",{gasLimit: 1000000});

  console.log(tx.hash);

})();
