import { parseEther } from 'ethers/lib/utils';
import { kakiCaptainContract } from '~/utils/contract';
import { contractAddress } from "../../utils/contract";
import {formatEther} from 'ethers/lib/utils'

(async () => {
    const caption = await kakiCaptainContract();
    const adress1=await caption.nloAddress();
    console.log(adress1);
    //const tx = await caption.setNLOAddress("0x4d7541352aEea5cF34785e493BD7F9D2Ae58517A");
    //console.log(tx.hash);
    //const adress2=await caption.nloAddress();
    //console.log(adress2);
})();