import { parseEther } from 'ethers/lib/utils';
import { squidOpenBoxContract } from '~/utils/contract';
import {formatEther} from 'ethers/lib/utils'

(async () => {
    console.log('clear...');
    const openBox = await squidOpenBoxContract();

    const tx = await openBox.setInvalidTime(1640224800); //2021-12-23 10:00:00    
    console.log(tx.hash);

    let a = ['0xAD16C85081d3fA1618C329Cc041CAff4fEc97C63',
    '0x4450dB99260EC3140B4690F1c6bDd64d5d9644A9',
    '0x5EeBD2f03424DCF5F0244a54b3b1E7BE65B7891D',
    '0xc7Bd8d112EDf928A22A3aD1Eb97880C42d76cD4d',
    '0x343cC3d8480ec2Bd0591adB71d858FC4A9CE1a65',
    '0x13e4cB2a40faAfA3e4D196492725f7e7A850737c',
    '0x8204175DEf438eCb8Bf1842456d2f34c57E6F4d1',
    '0x62440E56cF828c65Ab0Db8f52523a18879e74Df3',
    '0xCc8b0b2296347305453B1D80a383d5597326614C',
    '0x4EeB39d9d2Cc3b3A2eCE2e416829a582bb3058f2',
    '0xF7875558dCf381B3d633D03B1f5F078Dee82dA16',
    '0xda65051ea6aEe9831580E299E2DC069f4cCF1633',
    '0xd4058D4ab2aAa4e90C9b74f60641e4E07aF93B57',
    '0xC5A0BF774DD62315e87Ad213342b21De8D12ba17',
    '0xAfd1CD9ab236c65F63603BD0d932b5Ac8992aae1',
    '0x31f5F88327Ea143322aB493F53FDaa42Da788BA0',
    '0x3d703c4615AFD872F410cc42b2adc04694dC01F2',
    '0x8B12B7b9F963379b721D061af0BaF53bFfccF533',
    '0xFf4aCfd3bE0C851bE759A0491E6D6c85FeA96aFE',
    '0x952E34523f9d2977B35f6ea2bfAa020207569404',
    '0xaD2C40dFd17F09d2c9D341573652683BA892acD2',
    ];
    const tx2 =await openBox.clearClaimLimit(a);
    console.log(tx2.hash);

})();