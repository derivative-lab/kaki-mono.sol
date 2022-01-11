import { parseEther } from 'ethers/lib/utils';
import { contractAddress, claimLockContract } from "../../utils/contract";
import { formatEther } from 'ethers/lib/utils'

(async () => {
  const claimlock = await claimLockContract();
  let a = await claimlock.getClaimableFarmReward("0xebb594b4e7afc089a061434e21ce3a6e4edbc5d1",3);
  console.log(a);
})();
