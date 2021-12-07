import { busdContract, oracleContract, squidTicketContract } from '~/utils/contract';
import { deploySquidGame } from '../../utils/deployer';


(async () => {
  const ticket = await squidTicketContract();
  const busd = await busdContract();
  const oracle = await oracleContract();
  await deploySquidGame(ticket, busd, oracle);
})();
