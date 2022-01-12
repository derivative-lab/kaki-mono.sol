

import { zeroAddress } from 'ethereumjs-util';
import { farmContract } from '~/utils/contract';
import { contractAddress } from '../../../utils/contract';


(async () => {

  const farm = await farmContract();

  // https://github.com/alpaca-finance/bsc-alpaca-contract/blob/main/.testnet.json

  const tx = await farm.addPool(
    200, // allocation point
   contractAddress.kakiBnbLP, // tokenAddress
    3 * 10000,  // price
    zeroAddress(), // vault
    zeroAddress(), // ibBUSD
    zeroAddress(), // fairLaunch
    0,  // fairLaunch pid
    false, // native
    "KAKIBNB-LP" // name
  );

  console.log(tx.hash);

})();
