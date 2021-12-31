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

        await mysteryBox.setApprovalForAll(captainClaim.address, true);
        await kakiCaptain.setupAdmin(captainClaim.address);
        await mysteryBox.mint(users[0].address);
        await mysteryBox.mint(users[0].address);
        await mysteryBox.mint(users[0].address);
        await mysteryBox.mint(users[0].address);

        //let tokenId = await captainClaim.mint({value: BigNumber.from("500000000000000000")});
        //console.log(tokenId);
        let balance = await kakiCaptain.balanceOf(users[0].address);
        //expect (balance).to.equal(1);
        await mysteryBox.setApprovalForAll(captainClaim.address, true);
        for (var i =0; i<4; i++) {
            let boxId = await mysteryBox.tokenOfOwnerByIndex(users[0].address, i);
            console.log("boxid", boxId);
        }
        
        //await captainClaim.switchByBox()
        });
    });
});