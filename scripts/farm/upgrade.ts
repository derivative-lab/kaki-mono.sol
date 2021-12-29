import { upgrade } from "~/utils/upgrader"
import { contractAddress } from '~/utils/contract';


(async () => {
  await upgrade(`farm/KakiGarden.sol`, contractAddress.farm);
})
