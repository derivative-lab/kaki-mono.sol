import {
  KakiSquidGame__factory,
  Ticket__factory,
  OpenBox__factory,
  AddressList__factory,
  CaptainClaim__factory,
} from "~/typechain";

(async () => {
  console.log(`\n`.repeat(5))
  for (const a of CaptainClaim__factory.abi.filter(
    (x) => x.stateMutability === "view"
  )) {
    console.log(a.name);
  }
  console.log(`\n`.repeat(5))
})();
