

import { farmContract } from '~/utils/contract';
import { printEtherResultArray } from '../../utils/logutil';
import { printEtherResult } from '~/utils/logutil';


(async () => {

  const farm = await farmContract();

  const pool = await farm.poolApr(1);
  printEtherResult(pool);

})();
