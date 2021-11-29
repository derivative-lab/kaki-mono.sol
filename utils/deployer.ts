import {ethers, upgrades, deployments} from 'hardhat';
import {
  MockChainLink,
  MockChainLink__factory,
  MockToken__factory,
  MockToken,
  KakiSquidGame__factory,
  KakiSquidGame,
} from '~/typechain';
import {getSigner} from '~/utils/contract';

export async function deployMockChainLink() {
  const signer0 = await getSigner(0);
  const factory = new MockChainLink__factory(signer0);
  const instance = await factory.deploy();
  await instance.deployed();
  return instance as MockChainLink;
}

export async function deployMockUsdt() {
  const signer0 = await getSigner(0);
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

export async function deploySquidGame(usdt: MockToken, chainlink: MockChainLink) {
  const signer0 = await getSigner(0);
  const factory = new KakiSquidGame__factory(signer0);
  const instance = await upgrades.deployProxy(factory, [usdt.address, chainlink.address]);
  console.log(`deploy squid game to: ${instance.address}`);
  await instance.deployed();
  return instance as KakiSquidGame;
}

export async function deployAll() {
  const usdt = await deployMockUsdt();
  const chainlink = await deployMockChainLink();
  const game = await deploySquidGame(usdt, chainlink);

  return {usdt, chainlink, game};
}
