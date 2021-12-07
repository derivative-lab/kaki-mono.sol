import { deployments, ethers, network } from 'hardhat';
import { AddressList__factory, MockChainLink__factory, MockToken__factory, Ticket__factory } from '~/typechain';


export const frontendUsedContracts = [
  'index',
  'tsconfig.json',
  'contractAddress',
  'commons',
  'package',
  //-------  Solidity files -----

  "IKakiSquidGame",
  "KakiSquidGame",
  "IOpenBox",
  "ITicket",
  "IERC20",
  "IBlindBox",
  "IBaseERC721",
];

export const mutiContractAddrs = {
  testnet: {
    busd: '0x0266693F9Df932aD7dA8a9b44C2129Ce8a87E81f',
    oracle: '0x048Cc75FF36d67aFCd25160AB5aa8Bde1FDa3F19',
    squidGame: '0xC76255D7E26A3d634Bd2CD4Ac84374e36C9798a5',
  },
  bsctest: {
    squidGame: '0x573efF8F0467187c178721813d880a145A6f5A52',
    busd: '0xE70b02A5Ae129F66687256b7a5e81cC871e347D7',
    oracle: '0x048Cc75FF36d67aFCd25160AB5aa8Bde1FDa3F19',
    blindBoxDrop: '0x26dEa25C01f43B2cf8Da3aCe68F0DD830a4399e5',
    squidAllowList: '0x405497ceb2E20C9E8ec5875d669ad6381BBEE79E',
    squidTicket: '0x7dc99344aA0053BC2DC16aE111e83C1315409a07',
    squidOpenBox: '0x7fc45201D0DBE2175c76995474D6394B8837C982',
  },
  bsc: {
    squidGame: '',
    busd: '',
    oracle: '0x8f55C31C0951C04d471744Eeef6a0d5903588EFe',
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
  },
  get squidAllowList() {
    return getItem('squidAllowList');
  },
  get squidTicket() {
    return getItem('squidTicket');
  },
  get squidOpenBox() {
    return getItem('squidOpenBox');
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
export async function squidAllowListContract(signerIndex = 0) {
  return AddressList__factory.connect(contractAddress.squidAllowList, await getSigner(signerIndex));
}

export async function squidTicketContract(signerIndex = 0) {
  return Ticket__factory.connect(contractAddress.squidTicket, await getSigner(signerIndex));
}
