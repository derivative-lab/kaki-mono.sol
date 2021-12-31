import { parseEther } from 'ethers/lib/utils';
import { mysteryBoxContract } from '../../utils/contract';
import { contractAddress } from "../../utils/contract";
import {formatEther} from 'ethers/lib/utils'

(async () => {
    const mBox = await mysteryBoxContract();
    for(var i =0; i< 10; i++) {
        const tx = await mBox.mint("0x5067611CEca1d47Bd6812936486F39cf8A378365");
        console.log(tx.hash);
        console.log(i);
    }
    
})();