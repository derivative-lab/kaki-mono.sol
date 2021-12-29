import { deployCaptainClaim } from '~/utils/deployer'
import { kakiCaptainContract, captainAllowListContract, captainMintContract } from '~/utils/contract'
import { CaptainClaim } from '~/typechain';
import {deploy} from '~/utils/upgrader';
(async () => {
  const captain = await kakiCaptainContract();
  const allowList = await captainAllowListContract();
  const mintList = await captainMintContract();


  const args : Parameters<CaptainClaim["initialize"]> = [
    captain.address,
    allowList.address,
    mintList.address
  ]
  // await deployOpenBox(ticket, busd, 1639649100, allowList);

  console.log({args})
  await deploy(`captain/CaptainClaim.sol`,args)
})()