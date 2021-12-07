import {
  KakiSquidGame,
  KakiSquidGame__factory,
  MockToken__factory,
  MockToken,
  MockChainLink,
  MockChainLink__factory,
} from '~/typechain';
import { deployments, ethers, getUnnamedAccounts, network, upgrades } from 'hardhat';
import { expect } from './chai-setup';
import { deployAll } from '~/utils/deployer';
import { setupUsers } from './utils';
import { parseEther } from 'ethers/lib/utils';
import { printEtherResult } from '../utils/logutil';

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

describe('open Box', async () => {
  it('claim', async () => {
    const { users, openBox, usdt, ticket, allowClaimTicket } = await setup();



  });
});
