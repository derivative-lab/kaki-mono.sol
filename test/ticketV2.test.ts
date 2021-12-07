import { expect } from "chai";
import "@nomiclabs/hardhat-waffle";
import {waffle, upgrades} from 'hardhat';
import {Contract, BigNumber} from 'ethers';
const {provider, createFixtureLoader} = waffle;
import {testEngine} from "../test-helpers/testEngine";
const {expectRevert} = require("@openzeppelin/test-helpers");

describe("ticket Test", function() {
    const accounts = provider.getWallets();
    const loadFixture = createFixtureLoader(accounts, provider);
    const owner = accounts[0];
    const user1 = accounts[1];
    const user2 = accounts[2];
    const user3 = accounts[3];

    let kakiBlindBox : Contract;
    let kakiTicket : Contract;
    let usdt : Contract;

    this.beforeEach(async() => {
        const t = await loadFixture(testEngine);

        kakiBlindBox = t.kakiBlindBox;
        kakiTicket = t.kakiTicket;
        usdt = t.uSDTToken;
    })

    context("should failed", async () => {
        it("", async () => {
            
        })
    })
})