import { parseEther } from 'ethers/lib/utils';
import { mysteryBoxContract } from '../../utils/contract';
import { contractAddress } from "../../utils/contract";
import {formatEther} from 'ethers/lib/utils'

(async () => {
    const mBox = await mysteryBoxContract();
    for(var i =0; i< 10; i++) {
        const tx = await mBox.mint("0x62b293CF6170C76ea908689f2eb93eB21e3f5084");
        console.log(tx.hash);
        console.log(i);
    }
    
})();