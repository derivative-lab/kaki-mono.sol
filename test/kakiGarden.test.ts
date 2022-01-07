import {
  KakiGarden,
  MockAlpacaToken__factory,
  MockFairLaunch__factory,
  MockAlpacaToken,
  MockFairLaunch,
  ClaimLock,
  ClaimLock__factory,
  MockValt,
  MockValt__factory,
  MockToken__factory,
} from '~/typechain';
import { deployments, ethers, getUnnamedAccounts, network, upgrades } from 'hardhat';
import { expect } from './chai-setup';
import { deployAll, deployKakiGarden } from '~/utils/deployer';
import { setupUsers } from './utils';
import { parseEther } from 'ethers/lib/utils';
import { printEtherResult } from '../utils/logutil';
import { getSigner } from '~/utils/contract';
import { toBuffer, fromUtf8, bufferToHex, zeroAddress } from 'ethereumjs-util'
import { BigNumber } from '@ethersproject/bignumber';


const setup = deployments.createFixture(async () => {

  const contracts = await deployAll();
  const signer = await getSigner();

  const usdt = await new MockToken__factory(signer).deploy('USDT', "USDT", 18, ethers.utils.parseEther(`1${'0'.repeat(10)}`));
  const wbnb = await new MockToken__factory(signer).deploy('WBNB', "WBNB", 18, ethers.utils.parseEther(`1${'0'.repeat(10)}`));
  const bnbValt = await new MockValt__factory(signer).deploy(wbnb.address);
  const usdtValt = await new MockValt__factory(signer).deploy(usdt.address);

  const block = await signer.provider?.getBlockNumber() as number;
  const alpaca = await new MockAlpacaToken__factory(signer).deploy(block, block + 20000 * 365);
  const fairLaunch = await new MockFairLaunch__factory(signer).deploy(alpaca.address, parseEther('100'), block);

  const singers = await ethers.getSigners();
  const accounts = singers.map((e) => e.address);
  const users = await setupUsers(accounts, {
    ...contracts,
    usdt,
    alpaca,
    fairLaunch,
    usdtValt,
    wbnb,
    bnbValt,
  });

  return {
    ...contracts,
    usdt,
    alpaca,
    fairLaunch,
    usdtValt,
    wbnb,
    bnbValt,
    users,
  };
});

const addPool = async () => {
  const all = await setup();
  const { garden, usdt, usdtValt, fairLaunch ,wbnb,bnbValt} = all;
  await fairLaunch.addPool(100, usdt.address, false)
  await fairLaunch.addPool(100, wbnb.address, false)


  await garden.addPool(100,zeroAddress(),100, bnbValt.address, bnbValt.address, fairLaunch.address,0,true, 'bnb-pool')
  await expect(garden.addPool(100, usdt.address, 1234, usdtValt.address, usdtValt.address, fairLaunch.address, 1, false, "usdt-pool")).not.reverted;

  return all;
}

describe('garden', async () => {
  it(`add pool`, async () => {
    const { users, garden } = await addPool();
  });

});
