import { parseEther } from 'ethers/lib/utils';
import { captainClaimContract } from '~/utils/contract';
import { contractAddress } from "../../utils/contract";
import {formatEther} from 'ethers/lib/utils'

(async () => {
    const ticket = await captainClaimContract();
    //const tx = await ticket.setupAdmin(contractAddress.captainClaim);
    console.log(tx.hash);
})();