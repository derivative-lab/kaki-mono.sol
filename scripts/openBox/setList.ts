import { parseEther } from 'ethers/lib/utils';
import { contractAddress, squidAllowListContract, squidOpenBoxContract } from '~/utils/contract';
import {formatEther} from 'ethers/lib/utils'

(async () => {

  const openBox = await squidOpenBoxContract();

  //const tx = await openBox.setClaimWhiteList(contractAddress.squidAllowList);
  let a = ['0xd6D134377027b5d48535701e30Bc9198E69af592']

  const allowList = await squidAllowListContract();

  const tx = await allowList.addToAddressList(a);
    // console.log(tx2.hash);
    console.log(tx.hash);
})();
