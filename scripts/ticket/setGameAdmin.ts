import { parseEther } from 'ethers/lib/utils';
import { squidTicketContract } from '~/utils/contract';
import {formatEther} from 'ethers/lib/utils'

(async () => {
    const ticket = await squidTicketContract();
    const tx = await ticket.setupAdmin('0x7fc45201D0DBE2175c76995474D6394B8837C982');
    console.log(tx.hash);
})();