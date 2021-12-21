import { parseEther } from 'ethers/lib/utils';
import { contractAddress, squidAllowListContract, squidOpenBoxContract } from '~/utils/contract';
import {formatEther} from 'ethers/lib/utils'

(async () => {

  const openBox = await squidOpenBoxContract();

    //const tx = await openBox.setClaimWhiteList(contractAddress.squidAllowList);
    //console.log(tx.hash);
    let a = ['0x82e47AeFEecB77e55eeEd7Cf6300f61DbBf366a8','0x4CCB55eAE466190D1Ca6e6E7a4032bFd8AFE69CE']

    const allowList = await squidAllowListContract();
    const tx2=await allowList.tryAddAddresses(a,{gasLimit:5000000});
    // const tx2 = await allowList.setupAdmin('0x8B52aB88dF16f88c4Ec885D89889C6deCAc7E221');
    console.log(tx2.hash);
    
})();
