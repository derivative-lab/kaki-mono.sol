import { parseEther } from 'ethers/lib/utils';
import { squidOpenBoxContract } from '~/utils/contract';
import {formatEther} from 'ethers/lib/utils'

(async () => {
    console.log('clear...');
    const openBox = await squidOpenBoxContract();


    let a = ['0xfFd4894ae25E47B0120cAB19E73fb248855Ff6Cf',
    '0xb4eD8d1Cee3DDF31b1C5b4aC31Fc99d55a9862b5',
    '0x8918760945AD8499d5DE361f17B839686080d67e', 
    '0x8B12B7b9F963379b721D061af0BaF53bFfccF533', 
    '0x952E34523f9d2977B35f6ea2bfAa020207569404', 
    '0x5EeBD2f03424DCF5F0244a54b3b1E7BE65B7891D', 
    '0x343cC3d8480ec2Bd0591adB71d858FC4A9CE1a65', 
    '0x8204175DEf438eCb8Bf1842456d2f34c57E6F4d1', 
    '0xda65051ea6aEe9831580E299E2DC069f4cCF1633', 
    '0x4450dB99260EC3140B4690F1c6bDd64d5d9644A9', 
    '0xCc8b0b2296347305453B1D80a383d5597326614C', 
    '0x13e4cB2a40faAfA3e4D196492725f7e7A850737c', 
      
    ];

 

    const tx2 =await openBox.clearClaimLimit(a);
    console.log(tx2.hash);

})();