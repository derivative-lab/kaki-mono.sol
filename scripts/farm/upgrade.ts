import { upgrade } from "~/utils/upgrader"
import { contractAddress, getSigner } from '~/utils/contract';


(async () => {
  const signer = await getSigner(0)
  console.log("signer:", signer.address);
  await upgrade(`farm/KakiGarden.sol`, contractAddress.farm);
})();
