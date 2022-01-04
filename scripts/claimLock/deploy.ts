import { farmContract, kakiContract } from '~/utils/contract'
import { ClaimLock } from '~/typechain';
import {deploy} from '~/utils/upgrader';
(async () => {
  const farm = await farmContract();
  const kakiToken = await kakiContract();

  const args : Parameters<ClaimLock["initialize"]> = [
    farm.address,
    kakiToken.address
  ]

  console.log({args})
  await deploy(`claimLock/ClaimLock.sol`,args)
})()


