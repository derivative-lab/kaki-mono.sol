import { parseEther } from 'ethers/lib/utils';
import { contractAddress, squidAllowListContract, squidOpenBoxContract } from '~/utils/contract';
import {formatEther} from 'ethers/lib/utils'

(async () => {

  const openBox = await squidOpenBoxContract();

   
    const allowList = await squidAllowListContract();
    //const len=await allowList.length();
    //console.log(len.toString());
    /*for(let i=0;i<Number(len);i++){
        const address=await allowList.addressAt(i);
        const limit=await openBox.getClaimLimit(address);
        if(limit.eq(0)){
            console.log(address,limit.toString());
        }
        if(i%10==0){
            console.log(i);
        }
            
    }*/
    
    const limit=await openBox.getClaimLimit('0xe206189Dc09C52a32630A972B33b911205B45F89');
    console.log(limit.toString());
})();
