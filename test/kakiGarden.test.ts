// import {
//   KakiGarden
// } from '~/typechain';
// import { deployments, ethers, getUnnamedAccounts, network, upgrades } from 'hardhat';
// import { expect } from './chai-setup';
// import { deployAll, deployKakiGarden } from '~/utils/deployer';
// import { setupUsers } from './utils';
// import { parseEther } from 'ethers/lib/utils';
// import { printEtherResult } from '../utils/logutil';
// import { getSigner } from '~/utils/contract';
// import { toBuffer, fromUtf8, bufferToHex } from 'ethereumjs-util'
// import { BigNumber } from '@ethersproject/bignumber';


// const setup = deployments.createFixture(async () => {
//   const contracts = await deployAll();
//   const singers = await ethers.getSigners();
//   const accounts = singers.map((e) => e.address);
//   const users = await setupUsers(accounts, contracts);

//   return {
//     ...contracts,
//     users,
//   };
// });

// describe('garden', async () => {
//   it(`signer`, async () => {
//     const { users, garden } = await setup();
//   })

// });
