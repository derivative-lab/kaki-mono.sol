import { parseEther } from 'ethers/lib/utils';
import { mysteryBoxContract } from '../../utils/contract';
import { contractAddress } from "../../utils/contract";
import {formatEther} from 'ethers/lib/utils'

(async () => {
    const mBox = await mysteryBoxContract();
    for(var i =0; i< 10; i++) {
        const tx = await mBox.mint("0x62b293CF6170C76ea908689f2eb93eB21e3f5084");
        const tx2 = await mBox.mint("0x7430b734205366542B59541bC1201C46E666175c");
        console.log(tx.hash);
        console.log(tx2.hash);
    }
    
})();