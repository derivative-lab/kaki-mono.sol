import { deployments, ethers, network } from 'hardhat';
import { AddressList__factory, MockChainLink__factory, MockToken__factory, Ticket__factory, OpenBox__factory, KakiSquidGame, KakiSquidGame__factory } from '~/typechain';


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
  "AddressList",
];

export const mutiContractAddrs = {
  testnet: {
    busd: '0x0266693F9Df932aD7dA8a9b44C2129Ce8a87E81f',
    oracle: '0x048Cc75FF36d67aFCd25160AB5aa8Bde1FDa3F19',
    squidGame: '0xC76255D7E26A3d634Bd2CD4Ac84374e36C9798a5',
  },
  bsctest: {
    squidGame: '0x94c9f5732c77b77f53a7E25C37f53D8731f054b6',
    squidShortGame: '0x8b256bbA54B3f630fb172C5A3e4400DcbDbB469F',
    busd: '0xE70b02A5Ae129F66687256b7a5e81cC871e347D7',
    oracle: '0x8137934cF53e9ca1B4e75919dacc0364693fa69A',
    blindBoxDrop: '0x26dEa25C01f43B2cf8Da3aCe68F0DD830a4399e5',
    squidAllowList: '0xad6d691fdd595D747F30f5b0C4f05d7d1E59B9F6',
    squidTicket: '0x7dc99344aA0053BC2DC16aE111e83C1315409a07',
    squidOpenBox: '0x7fc45201D0DBE2175c76995474D6394B8837C982',
  },
  bsc: {
    squidGame: '0x837b8bdC93f6f7F0eb28fA3a1d80A7aB86ce854f',
    busd: '0xe9e7cea3dedca5984780bafc599bd69add087d56',
    oracle: '0x8f55C31C0951C04d471744Eeef6a0d5903588EFe',
    squidTicket: '0xeC386352ab845a30BDCdb358D743F66487C6dF3f',
    squidAllowList: '0x43bd49e5ad1173874ca5eb714858ec2af08d6e87',
    squidOpenBox: '0x67bab7f7dcde65738ef3db51e4148df1e5108354',
  }
};

export const contractAddress = {
  get squidGame() {
    return getItem('squidGame');
  },
  get squidShortGame() {
    return getItem('squidShortGame');
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

export async function squidOpenBoxContract(signerIndex = 0) {
  return OpenBox__factory.connect(contractAddress.squidOpenBox, await getSigner(signerIndex));
}


export async function squidGameContract(signerIndex = 0) {
  return KakiSquidGame__factory.connect(contractAddress.squidGame, await getSigner(signerIndex));
}
