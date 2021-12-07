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
  context("should success", async() => {
    it('claim', async () => {
      const { users, openBox, usdt, ticket, allowClaimTicket } = await setup();
      for (let i = 1; i < users.length; i++) {
        await usdt.transfer(users[i].address, parseEther('10000'));
      }
  
      for (let i = 0; i < users.length; i++) {
        await users[i].usdt.approve(openBox.address, parseEther(`1${'0'.repeat(20)}`));
      }
    });
  
    it('buyTicket', async () => {
      const { users, openBox, usdt, ticket, allowClaimTicket } = await setup();
      for (let i = 1; i < users.length; i++) {
        await usdt.transfer(users[i].address, parseEther('10000'));
      }
  
      for (let i = 0; i < users.length; i++) {
        await users[i].usdt.approve(openBox.address, parseEther(`1${'0'.repeat(20)}`));
      }
  
      for (let i = 0; i < users.length; i++) {
        await users[i].openBox.buyTicket();
        let balanceOfUser = (await ticket.balanceOf(users[i].address));
        expect(balanceOfUser).to.equal(1);
      }
    })
  
    it('buyTicketMul', async () => {
      const { users, openBox, usdt, ticket, allowClaimTicket } = await setup();
      for (let i = 1; i < users.length; i++) {
        await usdt.transfer(users[i].address, parseEther('10000'));
      }
  
      for (let i = 0; i < users.length; i++) {
        await users[i].usdt.approve(openBox.address, parseEther(`1${'0'.repeat(20)}`));
      }
  
      for (let i = 0; i < users.length; i++) {
        await users[i].openBox.buyTicketMul(2);
        let balanceOfUser = (await ticket.balanceOf(users[i].address));
        expect(balanceOfUser).to.equal(2);
      }
    })
  })
  
  context("should failed", async() => {
    it('buyTicketMul', async () => {
      const { users, openBox, usdt, ticket, allowClaimTicket } = await setup();
      await openBox.setAble();
      await usdt.transfer(users[0].address, parseEther('10000'));
      await users[1].openBox.buyTicketMul(2);
    })
  })
});
