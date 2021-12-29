import { parseEther } from 'ethers/lib/utils';
import { captainClaimContract } from '~/utils/contract';
import { contractAddress } from "../../utils/contract";
import {formatEther} from 'ethers/lib/utils'

(async () => {
    const captain = await captainClaimContract();
    for(var i = 0; i < 5; i++) {
        const tx = await captain.setTokenIdList(1+404*i,404*(i+1));
        console.log(tx.hash);
    }
    
})();