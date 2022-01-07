import { parseEther } from 'ethers/lib/utils';
import { contractAddress, squidAllowListContract, squidOpenBoxContract } from '~/utils/contract';
import {formatEther} from 'ethers/lib/utils'

(async () => {

  const openBox = await squidOpenBoxContract();
    console.log('set List...');
    //const tx = await openBox.setClaimWhiteList(contractAddress.squidAllowList);
    //console.log(tx.hash);
    let a = ['0xd4Df34Bc12D0cf06828705572881bd60aCC7F26E',

  ]

    const allowList = await squidAllowListContract();
    const tx2=await allowList.tryAddAddresses(a);
    // const tx2 = await allowList.setupAdmin('0x8B52aB88dF16f88c4Ec885D89889C6deCAc7E221');
    console.log(tx2.hash);
    
})();
