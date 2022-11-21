import { ethers } from "hardhat";
//0x5093018AB7cbAD8564fCDeFa335C9Cb0e49d2A2A
// npx hardhat verify 0x643546B7F21Fe54AD6cE617c3f1c09D8B8ba288C --network testnet --contract contracts/swap.sol:SwapTest
async function main() {
  let [owner] = await ethers.getSigners();
  const pancakeswapRouter ="0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3";
  const bikeryswapRouter = "0xCDe540d7eAFE93aC5fE6233Bee57E1270D3E330F";
  const tokenAggregateContractAddress = [
    "0x143db3CEEfbdfe5631aDD3E50f7614B6ba708BA7", //eth
    "0xE4eE17114774713d2De0eC0f035d4F7665fc025D", //Dai
    "0xEca2605f0BCF2BA5966372C99837b1F182d3D620", //usdt
    "0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526", //wbnb
    "0x9331b55D9830EF609A2aBCfAc0FBCE050A52fdEa"  //busd
  ];
  const Test = await ethers.getContractFactory("SwapTest");
  const test = await Test.deploy();
  await test.deployed();
  console.log("test contract",test.address);
  await test.connect(owner).addRouter(pancakeswapRouter);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
