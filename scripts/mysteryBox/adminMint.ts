import { parseEther } from 'ethers/lib/utils';
import { mysteryBoxContract } from '../../utils/contract';
import { contractAddress } from "../../utils/contract";
import {formatEther} from 'ethers/lib/utils'

(async () => {
    const mBox = await mysteryBoxContract();
    const tx = await mBox.mint("0x8B52aB88dF16f88c4Ec885D89889C6deCAc7E221");
    console.log(tx.hash);
})();