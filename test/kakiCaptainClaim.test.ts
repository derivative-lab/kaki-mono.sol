import { MysteryBox } from '~/typechain';
import { deployments, ethers, getUnnamedAccounts, network, upgrades } from 'hardhat';
import { expect } from './chai-setup';
import { deployAll, deployCaptainClaim } from '~/utils/deployer';
import { setupUsers } from './utils';
import { parseEther } from 'ethers/lib/utils';
import { printEtherResult } from '../utils/logutil';
import { getSigner } from '~/utils/contract';
import { toBuffer, fromUtf8, bufferToHex } from 'ethereumjs-util'
import { BigNumber } from '@ethersproject/bignumber';


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

describe('claim', async () => {
    context("should success", async() => {
      it('setList', async () => {
        const { users, captainClaim, mysteryBox, kakiCaptain} = await setup();
        await captainClaim.setTokenIdList(1, 100);

        let a = await captainClaim.getList();
        console.log(a);

        mysteryBox.setApprovalForAll(captainClaim.address, true);
        kakiCaptain.setupAdmin(captainClaim.address);
        mysteryBox.mint(users[0].address);
        
        });
    });
});