import {ethers, upgrades} from 'hardhat';
import {Signer, Contract, BigNumber} from 'ethers';

interface TestEngine {
  uSDTToken: Contract;
  mockChainLink: Contract;
  kakiSquidGame: Contract;
}

export async function testEngine(): Promise<TestEngine> {
  const usdtAmount = BigNumber.from('200000000000000000000000');

  const MockToken = await ethers.getContractFactory('MockToken');
  const MockChainLink = await ethers.getContractFactory('MockChainLink');
  const MockKakiSquidGame = await ethers.getContractFactory('MockKakiSquidGame');

  const uSDTToken = await MockToken.deploy('Tether USD', 'USDT', 18, usdtAmount);
  const mockChainLink = await MockChainLink.deploy();

  await uSDTToken.deployed();
  console.log('=======================deployer uSDTToken=========================');
  console.log('uSDTToken address: ' + uSDTToken.address);

  await mockChainLink.deployed();
  console.log('=======================deployer mockChainLink=========================');
  console.log('mockChainLink address: ' + mockChainLink.address);

  const kakiSquidGame = await upgrades.deployProxy(MockKakiSquidGame, [uSDTToken.address, mockChainLink.address]);
  console.log('kakiSquidGame address: ' + kakiSquidGame.address);

  return {
    uSDTToken,
    mockChainLink,
    kakiSquidGame,
  };
}
