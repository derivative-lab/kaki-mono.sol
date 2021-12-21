import { parseEther } from 'ethers/lib/utils';
import { squidOpenBoxContract } from '~/utils/contract';
import {formatEther} from 'ethers/lib/utils'

(async () => {
    const openBox = await squidOpenBoxContract();
    let a = ['0xe206189Dc09C52a32630A972B33b911205B45F89'];
    const tx =await openBox.clearClaimLimit(a);
    console.log(tx.hash);
})();