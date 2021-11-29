import {getSigner} from '~/utils/contract';
import chalk from 'chalk';
import {BaseContract, BigNumber, CallOverrides, ContractFactory, Overrides, Signer} from 'ethers';
import {ethers, network, upgrades} from 'hardhat';
import {bumpVersion} from './bumpVersion';
import gitP, {SimpleGit} from 'simple-git/promise';
import {TransactionRequest} from '@ethersproject/providers';

declare class MyContract extends BaseContract {
  version(overrides?: CallOverrides): Promise<BigNumber>;
}

declare class MyContractFactory extends ContractFactory {
  constructor(signer?: Signer);
  deploy(overrides?: Overrides & {from?: string | Promise<string>}): Promise<MyContract>;
  getDeployTransaction(overrides?: Overrides & {from?: string | Promise<string>}): TransactionRequest;
  attach(address: string): MyContract;
  connect(signer: Signer): MyContractFactory;
}

const manifestRepo = 'git@github.com:derivative-lab/kaki-Squid.openzeppelin.git';

const origin = 'origin';
export async function upgrade(fileName: string, address: string, factory: MyContractFactory | any, check = true) {
  const name = fileName.split('.')[0];

  const narr = name.split('/');
  const fname = narr[narr.length - 1];

  const repo = gitP('./.openzeppelin');

  const branchName = `${name}-${network.name}`;

  // if (!(await repo.checkIsRepo())) {
  const rst = await repo.init();
  // }
  const r = await repo.remote(['-v']);
  if (!(r && r.includes(origin))) {
    await repo.addRemote(origin, manifestRepo);
  }

  if (check) {
    if (await (await repo.status()).isClean()) {
      try {
        await repo.fetch(origin, branchName);
        const ck = await repo.checkout(branchName);
      } catch (e) {
        console.log(`please prepare branch: ${chalk.cyan(branchName)} for manifest at ${chalk.green('.openzeppelin')}`);
        throw e;
      }
      await repo.pull(origin, branchName);
    } else {
      throw new Error(`mainifest repo not clean > .openzeppelin, please check`);
    }
  }
  const signer0 = (await ethers.getSigners())[0];
  const contract = await ethers.getContractAt(fname, address);
  const vb = (await contract.version()).toString();
  console.log(`will upgrade ${chalk.green(branchName)}, current version: ${chalk.cyan(vb)} address: ${address}`);
  const instance = await upgrades.upgradeProxy(address, new factory(signer0));

  const version = await instance.version();
  const v = version.toString();
  console.log(`${chalk.green(fileName)} upgrade to ${chalk.green(v)} ${chalk.cyan(address)}`);

  if (check) {
    await repo.add('.');
    await repo.commit(`${name} - v${v}`);
    await repo.push(origin, branchName);
  }

  const nextv = await bumpVersion(fileName);
  console.log(`bump  version to ${chalk.cyan(nextv.toString())}`);
}

export async function deploy(fileName: string, factory: MyContractFactory | any, args = [], check = true) {
  const name = fileName.split('.')[0];
  const repo = gitP('./.openzeppelin');
  const branchName = `${name}-${network.name}`;
  const rst = await repo.init();
  // }
  const r = await repo.remote(['-v']);
  if (!(r && r.includes(origin))) {
    await repo.addRemote(origin, manifestRepo);
  }
  if (check) {
    if (await (await repo.status()).isClean()) {
      try {
        await repo.fetch(origin, branchName);
        const ck = await repo.checkout(branchName);
      } catch (e) {
        console.log(`please prepare branch: ${chalk.cyan(branchName)} for manifest at ${chalk.green('.openzeppelin')}`);
        throw e;
      }
      await repo.pull(origin, branchName);
    } else {
      throw new Error(`mainifest repo not clean > .openzeppelin, please check`);
    }
  }
  console.log(`will deploy ${chalk.green(branchName)}`);

  const instance = await upgrades.deployProxy(new factory(await getSigner(0)), args);
  console.log(`${name} deploy to ${instance.address}`);
  const nextv = await bumpVersion(fileName);
  console.log(`bump  version to ${chalk.cyan(nextv.toString())}`);
  if (check) {
    await repo.add('.');
    await repo.commit(`${name} - v${nextv}`);
    await repo.push(origin, branchName);
  }
}
