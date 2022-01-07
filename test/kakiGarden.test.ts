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
import { toBuffer, fromUtf8, bufferToHex } from 'ethereumjs-util'
import { BigNumber } from '@ethersproject/bignumber';


const setup = deployments.createFixture(async () => {

  const contracts = await deployAll();
  const signer = await getSigner();

  const usdt = await new MockToken__factory(signer).deploy('USDT', "USDT", 18, ethers.utils.parseEther(`1${'0'.repeat(10)}`));
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
    usdtValt
  });

  return {
    ...contracts,
    usdt,
    alpaca,
    fairLaunch,
    usdtValt,
    users,
  };
});

const addPool = async () => {
  const all = await setup();
  const { garden, usdt, usdtValt, fairLaunch } = all;
  await fairLaunch.addPool(100, usdt.address, false)

  await garden.addPool(100, usdt.address, 1234, usdtValt.address, usdtValt.address, fairLaunch.address, 0, false, "usdt-pool");

  return all;
}

describe('garden', async () => {
  it(`add pool`, async () => {
    const { users, garden } = await addPool();
  });

});
