import { kakiCaptainContract, mysteryBoxContract } from '~/utils/contract'
import { ClaimLock } from '~/typechain';
import {deploy} from '~/utils/upgrader';
(async () => {
  const captain = await kakiCaptainContract();
  const mysteryBox = await mysteryBoxContract();

  const args : Parameters<ClaimLock["initialize"]> = [
    "0xaE4364642f7Ed86971ea4a974a165C79c2F32766",

  ]

  console.log({args})
  await deploy(`claimLock/claimLock.sol`,args)
})()