/* eslint-disable */
// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const {ethers, upgrades} = require('hardhat');

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');

  // We get the contract to deploy
  console.log('start deploy...');
  const name = 'KAKI USDC';
  const symbol = 'kUSDC';

  const token = '0x0266693F9Df932aD7dA8a9b44C2129Ce8a87E81f'; //BUSD
  const oracle = '0x048Cc75FF36d67aFCd25160AB5aa8Bde1FDa3F19'; //BUSD
  const squidGame = await ethers.getContractFactory('kakiSquidGame');
  const squidGameProxy = await upgrades.deployProxy(squidGame, [token, oracle]);
  await squidGameProxy.deployed();
  console.log('squidGameProxy deployed to:', squidGameProxy.address);
  console.log('end deploy.');
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
