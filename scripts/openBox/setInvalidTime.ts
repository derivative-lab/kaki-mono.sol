import { parseEther } from 'ethers/lib/utils';
import { squidOpenBoxContract } from '~/utils/contract';
import {formatEther} from 'ethers/lib/utils'

(async () => {
    const openBox = await squidOpenBoxContract();
    const tx = await openBox.setInvalidTime(1640138400); //2021-12-22 10:00:00    
    console.log(tx.hash);
})();