import { deployOpenBox } from '~/utils/deployer'
import { busdContract, squidAllowListContract, squidTicketContract } from '~/utils/contract'
(async () => {
  const ticket = await squidTicketContract();
  const busd = await busdContract();
  const allowList = await squidAllowListContract();
  await deployOpenBox(ticket, busd, allowList);
})()
