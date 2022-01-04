import { parseEther } from 'ethers/lib/utils';
import { contractAddress, squidAllowListContract, squidOpenBoxContract } from '~/utils/contract';
import {formatEther} from 'ethers/lib/utils'

(async () => {

  const openBox = await squidOpenBoxContract();
    console.log('set List...');
    //const tx = await openBox.setClaimWhiteList(contractAddress.squidAllowList);
    //console.log(tx.hash);
    let a = ['0x8B12B7b9F963379b721D061af0BaF53bFfccF533',
    '0xe79C419c616f2AFDE3c535a38d0BDc471F777d29',
    '0xF7875558dCf381B3d633D03B1f5F078Dee82dA16', 
    '0x9763771312dfED5BD8F14c224626be2aF6c4102A', 
    '0x13e4cB2a40faAfA3e4D196492725f7e7A850737c', 
    '0x163810fD0b04ba5422013969B7287321118F3F55', 
    '0x20A13F1e2638c9784a031F291943b2A87B3f12A6', 
    '0x5EeBD2f03424DCF5F0244a54b3b1E7BE65B7891D', 
    '0xc69bBcD51B1e74572C7F29fA5d3D64b067235804', 
    '0x8204175DEf438eCb8Bf1842456d2f34c57E6F4d1', 
    '0xCc8b0b2296347305453B1D80a383d5597326614C', 
    '0xda65051ea6aEe9831580E299E2DC069f4cCF1633', 
    '0x8918760945AD8499d5DE361f17B839686080d67e', 
    '0x4450dB99260EC3140B4690F1c6bDd64d5d9644A9', 
    '0x3aD09Aabc9fFf246e73EB4F81fFf1D9B4115CB1C', 
    '0x9D082bFcA3a415900A41D01f9F1cA47879C9485d', 
    '0x43bFf8cb869EEF7D336453F68113B23Ed3220273', 
    '0x62440E56cF828c65Ab0Db8f52523a18879e74Df3', 
    '0x1534C74A0b25de4453ddcF8116c5a32aA7DEC202', 
    '0x9433504731cE9C24DF733761A3B4118DD2cBD9Ef',

  ]

    const allowList = await squidAllowListContract();
    const tx2=await allowList.tryAddAddresses(a);
    // const tx2 = await allowList.setupAdmin('0x8B52aB88dF16f88c4Ec885D89889C6deCAc7E221');
    console.log(tx2.hash);
    
})();
