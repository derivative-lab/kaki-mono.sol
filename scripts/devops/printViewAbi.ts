import {
  KakiSquidGame__factory,
  Ticket__factory,
  OpenBox__factory,
  AddressList__factory,
  CaptainClaim__factory,
  KakiGarden__factory,
} from "~/typechain";
import chalk from 'chalk';

(async () => {
  console.log(`\n`.repeat(5))
  for (const a of KakiGarden__factory.abi.filter(
    (x) => x.stateMutability === "view"
  )) {
    console.log(chalk.green(a.name));
  }
  console.log(`\n`.repeat(5))
})();
