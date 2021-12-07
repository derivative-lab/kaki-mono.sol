import { parseEther } from 'ethers/lib/utils';
import { squidAllowListContract } from '~/utils/contract';
import {formatEther} from 'ethers/lib/utils'

(async () => {
    let a = ['0x7430b734205366542B59541bC1201C46E666175c',
            '0x62b293CF6170C76ea908689f2eb93eB21e3f5084',
            '0x322f1123Bb4c622Aea976Fc33421a312e6bD350F']
    
    const allowList = await squidAllowListContract();

    // const tx2 = await allowList.setupAdmin('0x8B52aB88dF16f88c4Ec885D89889C6deCAc7E221');
    // console.log(tx2.hash);
    const tx = await allowList.addToAddressList(a);
    console.log(tx.hash);
})();