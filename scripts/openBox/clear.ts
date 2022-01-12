import { parseEther } from 'ethers/lib/utils';
import { squidOpenBoxContract } from '~/utils/contract';
import {formatEther} from 'ethers/lib/utils'

(async () => {
    console.log('clear...');
    const openBox = await squidOpenBoxContract();


    let a = ['0x2b94d683Cba7b6d3F0eac758bE483eF348161390',
    '0x8918760945AD8499d5DE361f17B839686080d67e',
    '0x8B12B7b9F963379b721D061af0BaF53bFfccF533', 
    '0x5EeBD2f03424DCF5F0244a54b3b1E7BE65B7891D', 
    '0x5180dd22E06Da143A8EB07D179534A1a58fD93e2', 
    '0xCc8b0b2296347305453B1D80a383d5597326614C', 
    '0xAD16C85081d3fA1618C329Cc041CAff4fEc97C63', 
    '0x4EeB39d9d2Cc3b3A2eCE2e416829a582bb3058f2', 
    '0x8204175DEf438eCb8Bf1842456d2f34c57E6F4d1', 
    '0x163810fD0b04ba5422013969B7287321118F3F55', 
    ];

 
    const tx2 =await openBox.clearClaimLimit(a);
    console.log(tx2.hash);

})();