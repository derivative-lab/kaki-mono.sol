import { parseEther } from 'ethers/lib/utils';
import { squidTicketContract, getSigner } from '~/utils/contract';
import { busdContract, contractAddress } from "../../utils/contract";
import { formatEther } from 'ethers/lib/utils'
import { expect } from '~/test/chai-setup';

var to = ["0x1B3c4A82705FCd878b691a31b6397aC275D04FE3",
    "0x4e3e5CC22E106671a17F9E22a68B93d106B4b0E9",
    "0x60aa87CF22EAFf9E36C036c4274cE1d409a11144",
    "0x087F35339Deb5F4B28Fd4AFDb9F933816137D7eC",
    "0x34B51ebB353CF3F9007662A53f1cD300790494c3",
    "0xF7E51D0E55B6793fc2865C2a7E8318ABa864e454",
    "0xcFb18C50df78352f7e413c77dEA128360e0e7c01",]

async function main() {
    const ticket = await squidTicketContract();


    const signer0 = await getSigner(0);
    const myTockets = await ticket.tokensOfOwner(signer0.address);

    expect(myTockets.length).eq(to.length)
    const tx = await ticket.batchTransfer(to, myTockets);

    console.log(tx.hash);

}

main();