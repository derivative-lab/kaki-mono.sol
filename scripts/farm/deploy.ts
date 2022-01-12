import { deploy } from "~/utils/upgrader"
import { KakiGarden } from '~/typechain';
import { getSigner } from "../../utils/contract";
import { parseEther } from 'ethers/lib/utils';


(async () => {

  const signer = await getSigner(0);
  const currentBlock = await signer.provider?.getBlockNumber() as number;

  const args: Parameters<KakiGarden["initialize"]> = [
    parseEther('10'),
    currentBlock + 100,
  ]
  await deploy(`farm/KakiGarden.sol`, args)
})()

