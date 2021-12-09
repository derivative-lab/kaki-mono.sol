import { deployments, ethers, getUnnamedAccounts, network, upgrades } from 'hardhat';
import { expect } from './chai-setup';
import { deployAll } from '~/utils/deployer';
import { setupUsers } from './utils';
import { parseEther } from 'ethers/lib/utils';
import { printEtherResult, printEtherResultArray } from '../utils/logutil';
import chalk from 'chalk';

const setup = deployments.createFixture(async () => {
  const contracts = await deployAll();
  const singers = await ethers.getSigners();
  const accounts = singers.map((e) => e.address);
  const users = await setupUsers(accounts, contracts);

  return {
    ...contracts,
    users,
  };
});

describe('noloss game', async () => {
  it('single user full flow', async () => {
    const { users, noLoss,usdt2, usdt, chainlink } = await setup();
    await users[0].usdt.approve(noLoss.address, parseEther(`1000000`));
    await usdt.transfer(users[0].address, parseEther('10000'));

    const now = await noLoss.getTimestamp();

    for (const u of users) {
     
    }
    let factionId=await noLoss._nextFactionId();
    console.log('factionId**************',factionId);
    await noLoss.createFaction(1);
    await network.provider.send("evm_increaseTime", [7 *24 *60 * 60]);
    const factionStatus = await noLoss._factionStatus(1);
    printEtherResult(factionStatus);
    printEtherResultArray(factionStatus);
    const kc=await noLoss.getChapterKC(1);
    console.log('kc:*********',kc);

    console.log('factionId**************',factionId);
    //await noLoss.fire();

    

  });
});
