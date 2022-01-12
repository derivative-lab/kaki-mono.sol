import { BigNumber } from '@ethersproject/bignumber';
import { ethers, upgrades, deployments } from 'hardhat';
import {
  MockChainLink,
  MockChainLink__factory,
  MockToken__factory,
  MockToken,
  KakiBlindBox__factory,
  KakiBlindBox,
  KakiSquidGame,
  KakiSquidGame__factory,
  KakiNoLoss,
  KakiNoLoss__factory,
  Ticket,
  Ticket__factory,
  AddressList,
  AddressList__factory,
  OpenBox,
  OpenBox__factory,
  IERC20,
  BlindBox,
  BlindBox__factory,
  KakiTicket,
  KakiTicket__factory
} from '~/typechain';

import { getSigner } from '~/utils/contract';

export async function deployMockChainLink() {
  const signer0 = await getSigner(0);
  const factory = new MockChainLink__factory(signer0);
  const instance = await factory.deploy();
  await instance.deployed();
  return instance as MockChainLink;
}

export async function deployMockUsdt(signerIndex = 0) {
  const signer0 = await getSigner(signerIndex);
  const factory = new MockToken__factory(signer0);
  const instance = await deployments.deploy('MockToken', {
    from: signer0.address,
    log: true,
    autoMine: true,
    args: ['USDT', 'USDT', 18, ethers.utils.parseEther(`1${'0'.repeat(10)}`)],
  });
  // factory.deploy('USDT', "USDT", 18, ethers.utils.parseEther(`1${'0'.repeat(10)}`));
  console.log(`deploy mock usdt to: ${instance.address}`);
  // await instance.deployed();
  return factory.attach(instance.address);
}

export async function deployMockERC20(name: string, symbol: string, issue: BigNumber, signerIndex = 0) {
  const signer0 = await getSigner(signerIndex);
  const factory = new MockToken__factory(signer0);
  const instance = await deployments.deploy('MockToken', {
    from: signer0.address,
    log: true,
    autoMine: true,
    args: [name, symbol, 18, issue],
  });
  // factory.deploy('USDT', "USDT", 18, ethers.utils.parseEther(`1${'0'.repeat(10)}`));
  console.log(`deploy mock ${name} - ${symbol} to: ${instance.address}`);
  // await instance.deployed();
  return factory.attach(instance.address);
}

export async function deployBlindBoxDrop() {
  const signer0 = await getSigner(0);
  const factory = new KakiBlindBox__factory(signer0);
  const instance = await upgrades.deployProxy(factory);
  console.log(`BlindBoxDrop deployed to : ${instance.address}`)
  return instance as KakiBlindBox;
}

export async function deploySquidGame(ticket: Ticket, usdt: MockToken, chainlink: MockChainLink, payWallet: string) {
  const signer0 = await getSigner(0);
  const factory = new KakiSquidGame__factory(signer0);
  const args: Parameters<KakiSquidGame['initialize']> = [
    ticket.address,
    usdt.address,
    chainlink.address,
    payWallet
  ];
  const instance = await upgrades.deployProxy(factory, args);
  console.log(`deploy squid game to: ${instance.address}`);
  await instance.deployed();
  return instance as KakiSquidGame;
}
export async function deployNoLoss(kaki: MockToken, bnbToken: MockToken, busdToken: MockToken, kakiBNBToken: MockToken, kakiBUSDToken: MockToken, chainlink: MockChainLink) {
  const signer0 = await getSigner(0);
  const factory = new KakiNoLoss__factory(signer0);
  const args: Parameters<KakiNoLoss['initialize']> = [
    kaki.address,
    bnbToken.address,
    busdToken.address,
    kakiBNBToken.address,
    kakiBUSDToken.address,
    chainlink.address
  ];
  const instance = await upgrades.deployProxy(factory, args);
  console.log(`deploy noloss to: ${instance.address}`);
  await instance.deployed();
  return instance as KakiNoLoss;
}

export async function deployTicket() {
  const signer0 = await getSigner(0);
  const factory = new Ticket__factory(signer0)
  const instance = await upgrades.deployProxy(factory);
  console.log(`Ticket deployed to : ${instance.address}`)
  return instance as Ticket;
}


export async function deployOpenBox(ticket: Ticket, busd: IERC20, invalidTime: number, allowList: AddressList) {
  const signer0 = await getSigner(0);
  const args: Parameters<OpenBox['initialize']> = [
    ticket.address,
    busd.address,
    invalidTime,
    allowList.address
  ];
  const factory = new OpenBox__factory(signer0)
  const instance = await upgrades.deployProxy(factory, args)
  console.log(`OpenBox deployed to : ${instance.address}`);
  return instance as OpenBox;
}

export async function deployAddrssList() {
  const signer0 = await getSigner(0);
  const factory = new AddressList__factory(signer0);
  const instance = await upgrades.deployProxy(factory);
  console.log(`AddressList deployed to : ${instance.address}`);
  return instance as AddressList;
}

export async function deployBlindBox() {
  const signer0 = await getSigner(0);
  const factory = new BlindBox__factory(signer0);
  const instance = await upgrades.deployProxy(factory);
  console.log(`blindBox deployed to : ${instance.address}`);
  return instance as BlindBox;
}

export async function deployKakiTicket() {
  const signer0 = await getSigner(0);
  const factory = new KakiTicket__factory(signer0);
  const instance = await upgrades.deployProxy(factory);
  console.log(`kakiTicket deployed to : ${instance.address}`);
  return instance as KakiTicket;
}

export async function deployAll() {
  // const usdt = await deployMockUsdt();
  const kakiToken = await deployMockERC20('KAKI', 'KAKI', ethers.utils.parseEther(`1${'0'.repeat(10)}`));
  const usdt = await deployMockERC20('USDT', 'USDT', ethers.utils.parseEther(`1${'0'.repeat(10)}`));
  const kakiUsdtLp = await deployMockERC20('USDT-KAKI', 'uk-LP', ethers.utils.parseEther(`1${'0'.repeat(10)}`));
  const wbnbToken = await deployMockERC20('WBNB', 'WBNB', ethers.utils.parseEther(`1${'0'.repeat(10)}`));

  const kakiBnbLP = await deployMockERC20('BNB-KAKI', 'bk-LP', ethers.utils.parseEther(`1${'0'.repeat(10)}`));

  const chainlink = await deployMockChainLink();
  const ticket = await deployTicket();

  const signer0 = await getSigner(0);
  const allowList = await deployAddrssList();
  const openBox = await deployOpenBox(ticket, usdt, allowList);
  const game = await deploySquidGame(ticket, usdt, chainlink,signer0.address);
  const kakiTicket = await deployKakiTicket
  const blindBox = await deployBlindBox()

  return { usdt, kakiToken, wbnbToken, kakiUsdtLp, kakiBnbLP, chainlink, game, openBox, ticket, noLoss, allowClaimTicket: allowList };
}
