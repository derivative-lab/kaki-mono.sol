import { upgrade } from '~/utils/upgrader';
import { contractAddress } from '~/utils/contract';


(async ()=>{
  await upgrade(`kaki/Kaki.sol`, contractAddress.kaki)
})()
