import { ChainlinkRandoms } from './../typechain/ChainlinkRandoms.d';
import { CaptainClaim__factory } from './../typechain/factories/CaptainClaim__factory';
import { BlindBox, KakiCaptain__factory, KakiGarden__factory, KakiTicket, MysteryBox__factory } from './../typechain';
import { deployments, ethers, network } from 'hardhat';
import { AddressList__factory, MockChainLink__factory, MockToken__factory, Ticket__factory, OpenBox__factory, KakiSquidGame, KakiSquidGame__factory, BlindBox__factory, KakiTicket__factory, ERC20__factory, Kaki__factory, ClaimLock__factory, KakiNoLoss, KakiNoLoss__factory, Tools__factory, } from '~/typechain';


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
  "IKakiTicket",
  "IBlindBox",
  "KakiNoLoss",
];

export const webToolsContractNames = [
  'KakiSquidGame',
  'OpenBox',
  'Ticket',
  'AddressList',
  'CaptainClaim',
  'KakiGarden',
  "KakiNoLoss",
]

export const mutiContractAddrs = {
  testnet: {
    busd: '0x0266693F9Df932aD7dA8a9b44C2129Ce8a87E81f',
    oracle: '0x048Cc75FF36d67aFCd25160AB5aa8Bde1FDa3F19',
    squidGame: '0xC76255D7E26A3d634Bd2CD4Ac84374e36C9798a5',
  },
  bsctest: {
    squidGame: '0xeb34B8Fa0CbD53D334B1D0dD74f1398f78A7F78c',
    squidShortGame: '0x94c9f5732c77b77f53a7E25C37f53D8731f054b6',
    busd: '0xE70b02A5Ae129F66687256b7a5e81cC871e347D7',
    oracle: '0x8137934cF53e9ca1B4e75919dacc0364693fa69A',
    blindBoxDrop: '0x26dEa25C01f43B2cf8Da3aCe68F0DD830a4399e5',
    squidAllowList: '0xad6d691fdd595D747F30f5b0C4f05d7d1E59B9F6',
    squidTicket: '0x7dc99344aA0053BC2DC16aE111e83C1315409a07',
    squidOpenBox: '0x7fc45201D0DBE2175c76995474D6394B8837C982',
    facet: '0xDDA65b6020d85bFA89683E366B4423Bb29233eD6',
    farm: '0x1bA1806e76054cE4CdFBe91f5E7ebBa9c5B23996',
    kakiCaptain: '0x61E83D94f50b456b1d4e3E7Ccd39f402287CEb51',
    captainClaim: '0x3839bDA320D33338d2e7adBf75bc149206cd01f8',
    captainMintList: '',
    captainAllowList: '',
    mysteryBox: '0xCB6f81Ab02Ee81Aa9b9b34737B029C48ACF55705',
    chainlinkRandoms: '0xaE4364642f7Ed86971ea4a974a165C79c2F32766',
    claimLock: '0x504DC2CcA9B3BBa98295840D2185ae062939c093',
    kaki: '0xC09886236326c4596D7823B3E730BE8Cc83bB245',
    noLoss:'0xAA10049AB5532665b45E0b6CA6A9aEd72E41E991',
    kakiBusdLP: '0x2638708361adb219c9d4e8cee5e9753b2bb53f47',
    kakiBnbLP: '0xbb6236d81557569c2f45a110d7180bac7132ff46',
    tools: '0x34378172cB777D3CD4F13F9e10705139f27A76Ee',
    //ticket v2
    blindBox: '',
    kakiTicket: '0xa46ad14DE4B30E150062B032c55fA692DC60E31d',
  },
  bsc: {
    squidGame: '0x837b8bdC93f6f7F0eb28fA3a1d80A7aB86ce854f',
    busd: '0xe9e7cea3dedca5984780bafc599bd69add087d56',
    oracle: '0x8f55C31C0951C04d471744Eeef6a0d5903588EFe',
    squidTicket: '0xeC386352ab845a30BDCdb358D743F66487C6dF3f',
    squidAllowList: '0x390B7384dc96a5728BB08D2e864549b2dee64549',
    // squidAllowList: '0x43bd49e5ad1173874ca5eb714858ec2af08d6e87',
    squidOpenBox: '0x67bab7f7dcde65738ef3db51e4148df1e5108354',
    chainlinkRandoms: '0xDfd77b646ea6480eea4dA7abca6C74053d8D9753',
    mysteryBox: '0x5B771c6114825b3D8EFCa66956E37aC34d812a66',
    kakiCaptain: '0xFE99a9e79959475d85af2BD11277B9061d457fa2',
    captainClaim: '0x6d476bc0dA5a017853545fee3939624F7fBFa0A7',
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
  },
  get kakiTicket() {
    return getItem('kakiTicket');
  },
  get blindBox() {
    return getItem('blindBox');
  },
  get facet() {
    return getItem('facet');
  },
  get kakiCaptain() {
    return getItem('kakiCaptain');
  },
  get captainAllowList() {
    return getItem('captainAllowList');
  },
  get captainMintList() {
    return getItem('captainMintList');
  },
  get mysteryBox() {
    return getItem('mysteryBox');
  },
  get captainClaim() {
    return getItem('captainClaim');
  },
  get farm() {
    return getItem('farm');
  },
  get chainlinkRandoms() {
    return getItem('chainlinkRandoms');
  },
  get claimLock() {
    return getItem("claimLock");
  },
  get kaki() {
    return getItem('kaki');
  },
  get noLoss() {
    return getItem('noLoss');
  },
  get kakiBusdLP(){
    return getItem('kakiBusdLP');
  },
  get kakiBnbLP(){
    return getItem('kakiBnbLP');
  },
  get tools() {
    return getItem('tools');
  },
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

export async function kakiTicketContract(signerIndex = 0) {
  return KakiTicket__factory.connect(contractAddress.kakiTicket, await getSigner(signerIndex));
}

export async function blindBoxContract(signerIndex = 0) {
  return BlindBox__factory.connect(contractAddress.blindBox, await getSigner(signerIndex));
}

export async function kakiCaptainContract(signerIndex = 0) {
  return KakiCaptain__factory.connect(contractAddress.kakiCaptain, await getSigner(signerIndex));
}

export async function captainClaimContract(signerIndex = 0) {
  return CaptainClaim__factory.connect(contractAddress.captainClaim, await getSigner(signerIndex));
}

export async function captainAllowListContract(signerIndex = 0) {
  return AddressList__factory.connect(contractAddress.captainAllowList, await getSigner(signerIndex));
}

export async function captainMintContract(signerIndex = 0) {
  return AddressList__factory.connect(contractAddress.captainMintList, await getSigner(signerIndex));
}

export async function mysteryBoxContract(signerIndex = 0) {
  return MysteryBox__factory.connect(contractAddress.mysteryBox, await getSigner(signerIndex));
}

export async function farmContract(signerIndex = 0) {
  return KakiGarden__factory.connect(contractAddress.farm, await getSigner(signerIndex));
}

export async function claimLockContract(signerIndex = 0) {
  return ClaimLock__factory.connect(contractAddress.claimLock, await getSigner(signerIndex));
}

export async function kakiContract(signerIndex = 0) {
  return Kaki__factory.connect(contractAddress.kaki, await getSigner(signerIndex));
}


export async function noLossContract(signerIndex = 0) {
  return KakiNoLoss__factory.connect(contractAddress.noLoss, await getSigner(signerIndex));
}

export async function toolsContract(signerIndex = 0) {
  return Tools__factory.connect(contractAddress.tools, await getSigner(signerIndex));
}
