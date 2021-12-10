import { contractAddress, squidGameContract } from "../../utils/contract";


(async () => {
  const squidGame = await squidGameContract();
  const tx = await squidGame.chapterInvalid(1638950400);
  console.log(tx.hash);
})();
