import { squidAllowListContract } from '~/utils/contract';
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

describe('blindBox', async () => {
    context('should success', async() => {
        it('buy abox', async () => {
            const { users, blindBox, usdt, kakiTicket} = await setup();
            await kakiTicket.setupAdmin(blindBox.address);
            await usdt.transfer(users[0].address, parseEther('10000'));
            await usdt.approve(blindBox.address, parseEther(`1${'0'.repeat(20)}`))
            await blindBox.aBoxOpen();
            let balanceOfUser = (await kakiTicket.balanceOf(users[0].address));
            expect(balanceOfUser).to.equal(1);
        })

        it('buy bbox', async () => {
            const { users, blindBox, usdt, kakiTicket} = await setup();
            await kakiTicket.setupAdmin(blindBox.address);
            await usdt.transfer(users[0].address, parseEther('10000'));
            await usdt.approve(blindBox.address, parseEther(`1${'0'.repeat(20)}`))
            await blindBox.bBoxOpen();
            let balanceOfUser = (await kakiTicket.balanceOf(users[0].address));
            expect(balanceOfUser).to.equal(1);
        })

        it('combine success', async () => {
            const { users, blindBox, usdt, kakiTicket} = await setup();
            await kakiTicket.setupAdmin(blindBox.address);
            await usdt.transfer(users[0].address, parseEther('10000'));
            await usdt.approve(blindBox.address, parseEther(`1${'0'.repeat(20)}`))
            await blindBox.bBoxOpen();
            let balanceOfUser = (await kakiTicket.balanceOf(users[0].address));
            expect(balanceOfUser).to.equal(1);
        })
    })

    context('should failed', async() => {
        it('Not able', async () => {
            const { users, blindBox, usdt, ticket, allowClaimTicket } = await setup();
            await ticket.setupAdmin(blindBox.address);
            await blindBox.setAble();
            await usdt.transfer(users[0].address, parseEther('10000'));
            await users[0].usdt.approve(blindBox.address, parseEther(`1${'0'.repeat(20)}`));
            await expect(users[0].blindBox.aBoxOpen(), 'aBox open is not able.').revertedWith("Lock is enabled.");
            await expect(users[0].blindBox.bBoxOpen(), 'bBox open is not able.').revertedWith("Lock is enabled.");
        })

        it('combine invalid number of cap', async () => {
            const { users, blindBox, usdt ,ticket, allowClaimTicket} = await setup();
            await ticket.setupAdmin(blindBox.address);
            await users[1].usdt.approve(blindBox.address, parseEther(`1${'0'.repeat(20)}`));
            await expect(users[1].blindBox.combine([1,2,3], [1,2,3,4]), 'invalid number of captain').revertedWith("Invalid number of captain.");
        })

        it('combine not nft owner', async () => {
            const { users, blindBox, usdt ,ticket, allowClaimTicket} = await setup();
            await ticket.setupAdmin(blindBox.address);
            await users[1].usdt.approve(blindBox.address, parseEther(`1${'0'.repeat(20)}`));
            await expect(users[1].blindBox.combine([1,2,3], []), 'Not NFT owner.').revertedWith("Not NFT owner.");
        })
    })
})