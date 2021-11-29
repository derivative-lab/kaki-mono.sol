import {
  KakiSquidGame,
  KakiSquidGame__factory,
  MockToken__factory,
  MockToken,
  MockChainLink,
  MockChainLink__factory,
} from '~/typechain';
import { deployments, ethers, getUnnamedAccounts, network, upgrades } from 'hardhat';
import { expect } from './chai-setup';
import { deployAll } from '~/utils/deployer';
import { setupUsers } from './utils';
import { parseEther } from 'ethers/lib/utils';
import { printEtherResult } from '../utils/logutil';

const setup = deployments.createFixture(async () => {
  const contracts = await deployAll();
  const singers = await ethers.getSigners();
  const accounts = singers.map((e) => e.address);
  const users = await setupUsers(accounts, contracts);

  const { usdt, chainlink, game } = contracts;

  return {
    ...contracts,
    users,
  };
});

describe('Squid game', async () => {
  it('single user full flow', async () => {
    const { users, game, usdt, chainlink } = await setup();
    for (let i = 1; i < users.length; i++) {
      await usdt.transfer(users[i].address, parseEther('10000'));
    }
    for (let i = 0; i < users.length; i++) {
      await users[i].usdt.approve(game.address, parseEther(`1${'0'.repeat(20)}`));
    }
    await chainlink.setLatestAnswer(100).then((tx) => tx.wait());
    await usdt.approve(game.address, parseEther('1000000'));
    await game.updateNextGameTime((Date.now() / 1000 + 1 * 3600).toFixed(0)) // one hour later start game

    const nextGameTime = await game._nextGameTime();
    const chainNow = await game.getTimestamp();
    printEtherResult({ nextGameTime, chainNow }, 'nextGameTime');
    await expect(game.buyTicket(), 'buyTicket first').emit(game, 'BuyTicket');
    // await expect(game.buyTicket(), 'ticket buyed already').reverted;

    expect(await game.getRoundChip(), 'init round chip must eq 16').eq(16)

    await expect(game.addLoot(), 'The chapter is not start').revertedWith('The chapter is not start');

    // change chain time to nextGameTime
    // await network.provider.send("evm_increaseTime", [3600])
    await network.provider.send("evm_setNextBlockTimestamp", [nextGameTime.toNumber()]);
    await expect(game.addLoot(), 'addLoot').emit(game, 'AddLoot');
    await expect(game.addLoot(), 'duplicated addLoot').reverted;
    await expect(game.buyTicket(), 'must buy before addLoot').reverted;

    // round 1
    await expect(game.placeBet(1)).emit(game, 'PlaceBet');
    // await expect(game.placeBet(1),'can not dulicate placebet').reverted;

    await expect(game.settle()).reverted;
    await network.provider.send("evm_increaseTime", [3 * 60])
    await expect(users[1].game.placeBet(1), 'second user placeBet timeout').reverted;
    await network.provider.send("evm_increaseTime", [2 * 60])
    await expect(game.settle()).emit(game, 'Settle');

    // round 2
    await expect(game.placeBet(16)).reverted;
    await expect(game.placeBet(1)).emit(game, 'PlaceBet');
    await network.provider.send("evm_increaseTime", [5 * 60])
    await expect(game.settle()).emit(game, 'Settle');

    // round 3
    await expect(game.placeBet(1), 'round 3 place bet').emit(game, 'PlaceBet');
    await network.provider.send("evm_increaseTime", [5 * 60])
    await expect(game.settle()).emit(game, 'Settle');
    // rount 4
    await expect(game.placeBet(1)).emit(game, 'PlaceBet');
    await network.provider.send("evm_increaseTime", [5 * 60])
    await expect(game.settle()).emit(game, 'Settle');
    // rount 5
    await expect(game.placeBet(1)).emit(game, 'PlaceBet');
    await network.provider.send("evm_increaseTime", [5 * 60])
    await expect(game.settle()).emit(game, 'Settle');
    // rount 6
    await expect(game.placeBet(1), 'non round 6').reverted;
    // await network.provider.send("evm_increaseTime", [5 * 60])
    await expect(game.settle(), 'non round 6').reverted;



    const chapter = await game._chapter();
    const totalBonus = await game.getTotalBonus(chapter.sub(1));
    const user0Bonus = await users[0].game.getUserBonus();
    printEtherResult({ user0Bonus, totalBonus });

    // claim

    await expect(game.claim()).emit(game, 'Claim').withArgs(users[0].address, user0Bonus);

    // next chapter
    const chapter2NextGameTime = await game._nextGameTime();
    printEtherResult({ chainTime: await game.getTimestamp(), nextGameTime: chapter2NextGameTime, nextGameTimeDiff: nextGameTime.sub(chapter2NextGameTime) }, 'nextGameTime chapter2');
    await expect(game.addLoot(), 'addLoot for chapter2').revertedWith('The chapter is not start.');
    await expect(game.buyTicket(), 'buyTicket second chapter').emit(game, 'BuyTicket');
    await network.provider.send("evm_increaseTime", [5 * 60])
   await expect(game.addLoot(), 'addLoot for chapter2').emit(game, 'AddLoot');


  });

  it('multi user full flow', async () => {
    const { users, game, usdt, chainlink } = await setup();
    for (let i = 1; i < users.length; i++) {
      await usdt.transfer(users[i].address, parseEther('10000'));
    }
    for (let i = 0; i < users.length; i++) {
      await users[i].usdt.approve(game.address, parseEther(`1${'0'.repeat(20)}`));
    }

    await chainlink.setLatestAnswer(100).then((tx) => tx.wait());
  });

  it(`buy ticket without approve`, async () => {
    const { users, game, usdt, chainlink } = await setup();
    await expect(game.buyTicket()).reverted;
  });
});
