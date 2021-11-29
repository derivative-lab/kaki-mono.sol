import chaiModule from 'chai';
// import { chaiEthers } from "chai-ethers";
//  https://github.com/EthWorks/Waffle/blob/master/waffle-chai/package.json
import {waffleChai} from '@ethereum-waffle/chai';
chaiModule.use(waffleChai);
export = chaiModule;
