import {
  KakiSquidGame__factory,
  Ticket__factory,
  OpenBox__factory,
  AddressList__factory,
} from "~/typechain";

(async () => {
  console.log(`\n`.repeat(5))
  for (const a of AddressList__factory.abi.filter(
    (x) => x.stateMutability === "view"
  )) {
    console.log(a.name);
  }
  console.log(`\n`.repeat(5))
})();
