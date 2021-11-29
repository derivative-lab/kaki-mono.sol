import {HardhatRuntimeEnvironment} from 'hardhat/types';
import {DeployFunction} from 'hardhat-deploy/types';
import {parseEther} from 'ethers/lib/utils';

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const {deployments, getNamedAccounts, getUnnamedAccounts} = hre;
  const {deploy} = deployments;

  const [deployer] = await getUnnamedAccounts();

  await deploy('MockToken', {
    from: deployer,
    args: ['Tether', 'USDT', 18, parseEther('10000000000000')],
    log: true,
    autoMine: true, // speed up deployment on local network (ganache, hardhat), no effect on live networks
  });
};
export default func;
func.tags = ['MockToken', 'usdt'];
