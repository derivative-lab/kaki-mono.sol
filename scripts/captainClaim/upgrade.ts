import { contractAddress } from '~/utils/contract';
import { upgrade } from '~/utils/upgrader';
import { CaptainClaim__factory } from '~/typechain';


(async () => {
  await upgrade(`captain/CaptainClaim.sol`, contractAddress.captainClaim, CaptainClaim__factory)
})();