import { toolsContract } from '~/utils/contract';
import { parseEther } from 'ethers/lib/utils';

(async () => {
  const tools = await toolsContract();
  const vault = '0xf9d32C5E10Dd51511894b360e6bD39D7573450F9'
  const tx = await tools.deposit(vault, parseEther('0.1'), true, {gasLimit: 1000000});
  console.log(tx.hash);

  //const tx = await tools.depositAndWithdraw(vault, parseEther('0.1'), false)
})();
