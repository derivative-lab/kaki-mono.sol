import { parseEther } from 'ethers/lib/utils';
import { busdContract, contractAddress } from "../../utils/contract";


(async () => {

  const busd = await busdContract();
  const tx = await busd.approve('0x8b256bbA54B3f630fb172C5A3e4400DcbDbB469F', parseEther(`1000000`));

  console.log(tx.hash)
})();
