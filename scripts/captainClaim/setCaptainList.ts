import { parseEther } from 'ethers/lib/utils';
import { captainClaimContract } from '~/utils/contract';
import { contractAddress } from "../../utils/contract";
import {formatEther} from 'ethers/lib/utils'
// import _ from "lodash";



(async () => {
    const captain = await captainClaimContract();
    // const tokenIds = Array.from({length:2020}).map((e,i)=>i+1);
    // const group = _.chunk(tokenIds,500);
    const tx = await captain.setTokenIdList(1, 200,{gasLimit: 5000000});
    console.log(tx.hash);
    // for(var i = 0; i < 10; i++) {
    //     const tx = await captain.setTokenIdList(1 + 202*i, 202 * (i+1));
    //     console.log(tx.hash);
    // }
    
})();