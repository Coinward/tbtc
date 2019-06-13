const BytesLib = artifacts.require('BytesLib')
const BTCUtils = artifacts.require('BTCUtils')
const ValidateSPV = artifacts.require('ValidateSPV')
const TBTCConstants = artifacts.require('TBTCConstants')
const CheckBitcoinSigs = artifacts.require('CheckBitcoinSigs')

const OutsourceDepositLogging = artifacts.require('OutsourceDepositLogging')
const DepositLog = artifacts.require('DepositLog')
const DepositStates = artifacts.require('DepositStates')
const DepositUtils = artifacts.require('DepositUtils')
const DepositFunding = artifacts.require('DepositFunding')
const DepositRedemption = artifacts.require('DepositRedemption')
const DepositLiquidation = artifacts.require('DepositLiquidation')

const Deposit = artifacts.require('Deposit')

const TBTCSystemStub = artifacts.require('TBTCSystemStub')
const KeepBridge = artifacts.require('KeepBridge')

const TBTC = artifacts.require('TBTC')

const all = [BytesLib, BTCUtils, ValidateSPV, TBTCConstants, CheckBitcoinSigs,
  OutsourceDepositLogging, DepositLog, DepositStates, DepositUtils,
  DepositFunding, DepositRedemption, DepositLiquidation, Deposit, TBTCSystemStub,
  KeepBridge]

const uniswap = require('../uniswap')
const path = require('path')
const child_process = require('child_process')

const UniswapFactory = artifacts.require('UniswapDeployment')

async function deployUniswap(deployer) {
  // const uniswapDir = path.join(__dirname, '../uniswap')

  // await child_process.execFileSync(
  //   path.join(uniswapDir, 'deploy.sh'),
  //   { 
  //     cwd: uniswapDir
  //   }
  // );

  let {
    Exchange,
    Factory
  } = uniswap.getDeployments()
  
  // exchange proxy
  // await Promise.all([
  //   deployer.deploy(UniswapExchange, Exchange),
  //   deployer.deploy(UniswapFactory, Factory)
  // ])
  
  // await deployer.deploy(UniswapExchange, Exchange)

  // // factory proxy
  // await deployer.deploy(UniswapFactory, Factory)

  await deployer.deploy(UniswapDeployment, Factory, Exchange)

  return Factory;
}

module.exports = (deployer) => {
  if(process.env.NODE_ENV == 'test') return Promise.resolve();
  
  deployer.then(async () => {
    let uniswapFactoryAddress;

    try {
      uniswapFactoryAddress = await deployUniswap(deployer)
    } catch(err) {
      throw new Error(`uniswap deployment failed: ${err}`)
    }
    
    await deployer.deploy(BytesLib)

    await deployer.link(BytesLib, all)
    await deployer.deploy(BTCUtils)

    await deployer.link(BTCUtils, all)
    await deployer.deploy(ValidateSPV)
    await deployer.deploy(CheckBitcoinSigs)
    await deployer.deploy(TBTCConstants)
    await deployer.link(TBTCConstants, all)

    await deployer.link(CheckBitcoinSigs, all)
    await deployer.link(ValidateSPV, all)
    await deployer.deploy(DepositStates)
    await deployer.deploy(OutsourceDepositLogging)

    await deployer.link(OutsourceDepositLogging, all)
    await deployer.link(DepositStates, all)
    await deployer.deploy(DepositUtils)

    await deployer.link(DepositUtils, all)
    await deployer.deploy(DepositLiquidation)

    await deployer.link(DepositLiquidation, all)
    await deployer.deploy(DepositRedemption)
    await deployer.deploy(DepositFunding)

    await deployer.link(DepositFunding, all)
    await deployer.link(DepositRedemption, all)

    await deployer.deploy(Deposit)

    let tbtcSystem = await deployer.deploy(TBTCSystemStub)
    let tbtc = await deployer.deploy(TBTC)

    await tbtcSystem.setup(
      uniswapFactoryAddress,
      tbtc.address
    );
 
    await deployer.deploy(KeepBridge)
  })
}
