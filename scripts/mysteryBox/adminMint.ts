import { parseEther } from 'ethers/lib/utils';
import { mysteryBoxContract } from '../../utils/contract';
import { contractAddress } from "../../utils/contract";
import {formatEther} from 'ethers/lib/utils'

(async () => {
    const mBox = await mysteryBoxContract();
    //for(var i =0; i< 10; i++) {
        // const tx = await mBox.mint("0x471C5FE7175EEdaD67F3551eDc475a613BA1aAd1");
        // const tx1 = await mBox.mint("0x62b293CF6170C76ea908689f2eb93eB21e3f5084");
        // const tx2 = await mBox.mint("0x7430b734205366542B59541bC1201C46E666175c");
        // const tx3 = await mBox.mint("0xd7dFC7e4249c40f9915E64b3D343FEC00BA525eC");
    const tx = await mBox.batchMint("0xbd4B399C74e6C6cD77bb1cCB6252040F93C2eF7a", 1);

    console.log(tx.hash);
    //console.log(i);
    //}
    
})();