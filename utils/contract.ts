import { deployments, ethers, network } from 'hardhat';
import { MockChainLink__factory, MockToken__factory } from '~/typechain';


export const frontendUsedContracts = [
  'index',
  'tsconfig.json',
  'contractAddress',
  'commons',
  'package',
  //-------  Solidity files -----

  "IKakiSquidGame"
];

export const mutiContractAddrs = {
  testnet: {
    busd: '0x0266693F9Df932aD7dA8a9b44C2129Ce8a87E81f',
    oracle: '0x048Cc75FF36d67aFCd25160AB5aa8Bde1FDa3F19',
    squidGame: '0xC76255D7E26A3d634Bd2CD4Ac84374e36C9798a5',
  },
  bsctest: {
    squidGame: '0xabff29148B4B185f3Bd1692A938e6530E9Bde9Fa',
    busd: '0x0266693f9df932ad7da8a9b44c2129ce8a87e81f',
    oracle: '0x048Cc75FF36d67aFCd25160AB5aa8Bde1FDa3F19',
    blindBoxDrop: '0x26dEa25C01f43B2cf8Da3aCe68F0DD830a4399e5'
  },
  bsc: {
    squidGame: '',
    busd: '',
    oracle: '',
  }
};

export const contractAddress = {
  get squidGame() {
    return getItem('squidGame');
  },
  get busd() {
    return getItem('busd');
  },
  get oracle() {
    return getItem('oracle');
  }

};

function getItem(key: string) {
  if ((<any>mutiContractAddrs)[network.name][key]) {
    return (<any>mutiContractAddrs)[network.name][key];
  } else {
    return (<any>mutiContractAddrs.testnet)[key];
  }
}

export async function getDeployment(name: string) {
  return await deployments.get(name);
}

export async function getSigner(index = 0) {
  return (await ethers.getSigners())[index];
}



export async function busdContract() {
  return MockToken__factory.connect(contractAddress.busd, await getSigner(0));
}

export async function oracleContract() {
  return MockChainLink__factory.connect(contractAddress.oracle, await getSigner(0));
}
