import { KakiNoLoss__factory } from '~/typechain'
import { contractAddress } from '~/utils/contract';
import { upgrade } from '~/utils/upgrader';

(async () => {
  await upgrade(`no-loss/KakiNoLoss.sol`, contractAddress.noLoss)
})();
