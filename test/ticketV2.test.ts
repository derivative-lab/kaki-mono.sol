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
import { Console } from 'console';

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
            const { users, blindBox, usdt, kakiTicket, mockRand, mockKakiCaptain} = await setup();
            await kakiTicket.setupAdmin(blindBox.address);
            await mockKakiCaptain.mint(users[0].address, 1);
            await mockKakiCaptain.mint(users[0].address, 1350);
            await mockKakiCaptain.mint(users[0].address, 2020);
            
            await usdt.transfer(users[0].address, parseEther('10000'));
            await usdt.approve(blindBox.address, parseEther(`1${'0'.repeat(20)}`))
            await mockRand.setRandom(100);
            await blindBox.bBoxOpen();
            await mockRand.setRandom(70);
            await blindBox.bBoxOpen();
            await mockRand.setRandom(85);
            await blindBox.bBoxOpen();
            let balanceOfUser = (await kakiTicket.balanceOf(users[0].address));
            expect(balanceOfUser).to.equal(3);
            let a = await kakiTicket.tokenOfOwnerByIndex(users[0].address, 0);
            let b = await kakiTicket.tokenOfOwnerByIndex(users[0].address, 1);
            let c = await kakiTicket.tokenOfOwnerByIndex(users[0].address, 2);
            console.log("abc", a,b,c);
            console.log("*********************************************************");
            await mockRand.setRandom(1);
            await kakiTicket.setApprovalForAll(blindBox.address, true);
            console.log("*************333333333333333333333333333333**************");
            await blindBox.combine([1,2,3], [1,1350,2020]);
            let balanceOfUser2 = (await kakiTicket.balanceOf(users[0].address));
            expect(balanceOfUser2).to.equal(1);
        })

        it('combine fail', async () => {
            const { users, mockBlindBox, usdt, kakiTicket, mockRand, mockKakiCaptain} = await setup();
            await kakiTicket.setupAdmin(mockBlindBox.address);
            await mockKakiCaptain.mint(users[0].address, 1);
            await mockKakiCaptain.mint(users[0].address, 1350);
            await mockKakiCaptain.mint(users[0].address, 2020);
            
            await usdt.transfer(users[0].address, parseEther('10000'));
            await usdt.approve(mockBlindBox.address, parseEther(`1${'0'.repeat(20)}`))
            await mockBlindBox.bBoxOpen(100, 5);
            await mockBlindBox.bBoxOpen(70, 10);
            await mockBlindBox.bBoxOpen(85, 10);
            let balanceOfUser = (await kakiTicket.balanceOf(users[0].address));
            expect(balanceOfUser).to.equal(3);
            let a = await kakiTicket.tokenOfOwnerByIndex(users[0].address, 0);
            let b = await kakiTicket.tokenOfOwnerByIndex(users[0].address, 1);
            let c = await kakiTicket.tokenOfOwnerByIndex(users[0].address, 2);
            console.log("abc", a,b,c);
            console.log("*********************************************************");
            await mockRand.setRandom(99);
            await kakiTicket.setApprovalForAll(mockBlindBox.address, true);
            await mockBlindBox.combine([1,2,3], [1,1350,2020]);
            let a3 = await mockKakiCaptain.getCapInfo(1);
            let b3 = await mockKakiCaptain.getCapInfo(1200);
            let c3 = await mockKakiCaptain.getCapInfo(2020);
            console.log("a3b33c3", a3,b3,c3);
            let a2 = await kakiTicket.tokenOfOwnerByIndex(users[0].address, 0);
            console.log("a2***********************", a2);
            let balanceOfUser2 = (await kakiTicket.balanceOf(users[0].address));
            expect(balanceOfUser2).to.equal(0);
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

        // it('combine not nft owner', async () => {
        //     const { users, blindBox, usdt ,ticket, allowClaimTicket} = await setup();
        //     await ticket.setupAdmin(blindBox.address);
        //     await users[1].usdt.approve(blindBox.address, parseEther(`1${'0'.repeat(20)}`));
        //     await expect(users[1].blindBox.combine([1,2,3], []), 'Not NFT owner.').revertedWith("Not NFT owner.");
        // })
    })
})