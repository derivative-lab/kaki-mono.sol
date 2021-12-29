import { parseEther } from 'ethers/lib/utils';
import { contractAddress, squidAllowListContract, squidOpenBoxContract } from '~/utils/contract';
import {formatEther} from 'ethers/lib/utils'

(async () => {

  const openBox = await squidOpenBoxContract();
    console.log('set List...');
    //const tx = await openBox.setClaimWhiteList(contractAddress.squidAllowList);
    //console.log(tx.hash);
    let a = ['0x4450dB99260EC3140B4690F1c6bDd64d5d9644A9',
    '0x3aD09Aabc9fFf246e73EB4F81fFf1D9B4115CB1C',
    '0x13e4cB2a40faAfA3e4D196492725f7e7A850737c', 
    '0x7713Bc1610038f1e2D2b06b13231deEbb03310B1', 
    '0x5f832e5a03fF1ec8f3A4a58010E9461B6b7e4C24', 
    '0xda65051ea6aEe9831580E299E2DC069f4cCF1633', 
    '0xFf4aCfd3bE0C851bE759A0491E6D6c85FeA96aFE', 
    '0xAD16C85081d3fA1618C329Cc041CAff4fEc97C63', 
    '0x5180dd22E06Da143A8EB07D179534A1a58fD93e2', 
    '0xb6195F19ed5Fd93F9Cf311AAE2B547a9AC5095Db', 
    '0x62440E56cF828c65Ab0Db8f52523a18879e74Df3', 
    '0x8204175DEf438eCb8Bf1842456d2f34c57E6F4d1', 
    '0x4EeB39d9d2Cc3b3A2eCE2e416829a582bb3058f2', 
    '0xCc8b0b2296347305453B1D80a383d5597326614C', 
    '0x952E34523f9d2977B35f6ea2bfAa020207569404', 
    '0x56428C73C4fcc0C2B50b281C6f8858FE573BC5b9', 
    '0x2d59CD7112E36a223807C08a636CBd51eC928c6C', 
    '0x5EeBD2f03424DCF5F0244a54b3b1E7BE65B7891D', 
    '0x8B12B7b9F963379b721D061af0BaF53bFfccF533', 
    '0x163810fD0b04ba5422013969B7287321118F3F55',

  ]

    const allowList = await squidAllowListContract();
    const tx2=await allowList.tryAddAddresses(a);
    // const tx2 = await allowList.setupAdmin('0x8B52aB88dF16f88c4Ec885D89889C6deCAc7E221');
    console.log(tx2.hash);
    
})();
