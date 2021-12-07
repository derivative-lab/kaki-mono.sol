import {ethers, upgrades} from 'hardhat';
import {Signer, Contract, BigNumber} from 'ethers';

interface TestEngine {
  uSDTToken: Contract;
  mockChainLink: Contract;
  kakiSquidGame: Contract;
  kakiTicket: Contract;
  kakiBlindBox: Contract;
}

export async function testEngine(): Promise<TestEngine> {
  const usdtAmount = BigNumber.from('200000000000000000000000');

  const MockToken = await ethers.getContractFactory('MockToken');
  const MockChainLink = await ethers.getContractFactory('MockChainLink');
  const MockKakiSquidGame = await ethers.getContractFactory('MockKakiSquidGame');
  const MockKakiTicket = await ethers.getContractFactory('KakiTicket');
  const MockKakiBlindBox = await ethers.getContractFactory('KakiBlindBox');

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

  const kakiTicket = await upgrades.deployProxy(MockKakiTicket);
  console.log('kakiTicket address: ' + kakiTicket.address);

  const kakiBlindBox = await upgrades.deployProxy(MockKakiBlindBox, [kakiTicket.address, uSDTToken.address]);
  console.log('kakiBlindBox address:' + kakiBlindBox.address);

  return {
    uSDTToken,
    mockChainLink,
    kakiSquidGame,
    kakiTicket,
    kakiBlindBox
  };
}
