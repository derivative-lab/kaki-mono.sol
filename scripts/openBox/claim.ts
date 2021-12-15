import { parseEther } from 'ethers/lib/utils';
import { squidOpenBoxContract } from '~/utils/contract';
import {formatEther} from 'ethers/lib/utils'

(async () => {
    const openBox = await squidOpenBoxContract();
    const tx = await openBox.claim({gasLimit:400000});
    console.log(tx.hash);
})();