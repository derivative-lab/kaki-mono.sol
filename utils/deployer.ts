import { IKakiCaptain } from './../typechain/IKakiCaptain.d';
import { BigNumber } from '@ethersproject/bignumber';
import { ethers, upgrades, deployments } from 'hardhat';
import {
  MockChainLink,
  MockChainLink__factory,
  MockToken__factory,
  MockToken,
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
  KakiTicket__factory,
  ClaimLock,
  ClaimLock__factory,
  KakiGarden,
  KakiGarden__factory,
  KakiCaptain,
  KakiCaptain__factory,
  CaptainClaim,
  CaptainClaim__factory,
  MysteryBox,
  MysteryBox__factory

} from '~/typechain';

import { getSigner } from '~/utils/contract';
import { parseEther } from 'ethers/lib/utils';

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

// export async function deployBlindBoxDrop() {
//   const signer0 = await getSigner(0);
//   const factory = new KakiBlindBox__factory(signer0);
//   const instance = await upgrades.deployProxy(factory);
//   console.log(`BlindBoxDrop deployed to : ${instance.address}`)
//   return instance as KakiBlindBox;
// }
export async function deployKakiCaptain() {
  const signer = await getSigner(0);
  const factory = new KakiCaptain__factory(signer);
  const args: Parameters<KakiCaptain["initialize"]> = [];
  const instance = await upgrades.deployProxy(factory, args);
  console.log(`KakiCaptain deployed to: ${instance.address}`);
  return instance as KakiCaptain;
}

export async function deployMysteryBox() {
  const signer = await getSigner(0);
  const factory = new MysteryBox__factory(signer);
  const instance = await factory.deploy("https://ipfs.io/ipfs/QmbgMfXVThUP2s8vFeUD7AXQmqASSBG5bkqosf7XCFrMP1?filename=KakiSeedBox.json");
  await instance.deployed();
  console.log(`MysteryBox deployed to: ${instance.address}`);
  return instance as MysteryBox;
}

export async function deployCaptainClaim(kakiCaptain: KakiCaptain, mysteryBox: MysteryBox, mockChainlink: MockChainLink) {
  const signer = await getSigner(0);
  const args: Parameters<CaptainClaim["initialize"]> = [
    kakiCaptain.address,
    mysteryBox.address,
    mockChainlink.address
  ];
  const factory = new CaptainClaim__factory(signer);
  const instance = await upgrades.deployProxy(factory, args);
  console.log(`CaptainClaim deployed to: ${instance.address}`);
  return instance as CaptainClaim;
}

export async function deployKakiGarden(kakiToken: string) {
  const signer = await getSigner(0);
  const currentBlock = await signer.provider?.getBlockNumber() as number;
  const args: Parameters<KakiGarden["initialize"]> = [
    parseEther('10'),
    currentBlock + 10
  ];

  const factory = new KakiGarden__factory(signer);
  const instance = await upgrades.deployProxy(factory, args);
  console.log(`KakiGarden deployed to: ${instance.address}`);
  return instance as KakiGarden;
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
export async function deployNoLoss(caption:KakiCaptain,kaki: MockToken, bnbToken: MockToken, busdToken: MockToken, kakiBNBToken: MockToken, kakiBUSDToken: MockToken, chainlink: MockChainLink) {
  const signer0 = await getSigner(0);
  const factory = new KakiNoLoss__factory(signer0);
  const args: Parameters<KakiNoLoss['initialize']> = [
    caption.address,
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

export async function deployKakiTicket() {
  const signer0 = await getSigner(0);
  const factory = new KakiTicket__factory(signer0);
  const instance = await upgrades.deployProxy(factory);
  console.log(`kakiTicket deployed to : ${instance.address}`);
  return instance as KakiTicket;
}

export async function deployBlindBox(kakiTicket: KakiTicket, busd: IERC20, kakiCap: KakiCaptain, chainlink: MockChainLink) {
  const signer0 = await getSigner(0);
  const args: Parameters<BlindBox['initialize']> = [
    kakiTicket.address,
    busd.address,
    kakiCap.address,
    chainlink.address
  ];
  const factory = new BlindBox__factory(signer0);
  const instance = await upgrades.deployProxy(factory, args);
  console.log(`blindBox deployed to : ${instance.address}`);
  return instance as BlindBox;
}

// export async function deployClaimLock(farm: , trading: , kaki: IKaki, pool) {
//   const signer0 = await getSigner(0);
//   const args: Parameters<ClaimLock['initialize']> = [

//   ];
//   const factory = new ClaimLock__factory(signer0);
//   const instance = await upgrades.deployProxy(factory, args);
//   console.log(`blindBox deployed to : ${instance.address}`);
//   return instance as ClaimLock;
// }

export async function deployAll() {
  // const usdt = await deployMockUsdt();
  const kakiToken = await deployMockERC20('KAKI', 'KAKI', ethers.utils.parseEther(`1${'0'.repeat(10)}`));
  const usdt = await deployMockERC20('USDT', 'USDT', ethers.utils.parseEther(`1${'0'.repeat(10)}`));
  const kakiUsdtLp = await deployMockERC20('USDT-KAKI', 'uk-LP', ethers.utils.parseEther(`1${'0'.repeat(10)}`));
  const wbnbToken = await deployMockERC20('WBNB', 'WBNB', ethers.utils.parseEther(`1${'0'.repeat(10)}`));

  const kakiBnbLP = await deployMockERC20('BNB-KAKI', 'bk-LP', ethers.utils.parseEther(`1${'0'.repeat(10)}`));

  const chainlink = await deployMockChainLink();
  const ticket = await deployTicket();
  const kakiTicket = await deployKakiTicket();

  const signer0 = await getSigner(0);
  const allowList = await deployAddrssList();
  const openBox = await deployOpenBox(ticket, usdt, Math.ceil(Date.now() / 1000 + 24 * 3600), allowList);
  const game = await deploySquidGame(ticket, usdt, chainlink, signer0.address);
  const kakiCaptain = await deployKakiCaptain();
  const noLoss = await deployNoLoss(kakiCaptain,kakiToken, wbnbToken, usdt, kakiBnbLP, kakiUsdtLp, chainlink);
  const garden = await deployKakiGarden(kakiToken.address);
  const mysteryBox = await deployMysteryBox();
  const captainClaim = await deployCaptainClaim(kakiCaptain, mysteryBox, chainlink);
  const blindBox = await deployBlindBox(kakiTicket, usdt, kakiCaptain, chainlink);

  return { usdt, kakiToken, wbnbToken, kakiUsdtLp, kakiBnbLP, chainlink, game, openBox, ticket, allowClaimTicket: allowList, kakiTicket, garden, kakiCaptain, noLoss, mysteryBox, captainClaim, blindBox};
}
