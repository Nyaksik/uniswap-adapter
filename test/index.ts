import { artifacts, ethers, waffle } from "hardhat";
import { Artifact } from "hardhat/types";
import addLiquidity from "./addLiquidity";
import swap from "./swap";

export default describe("Uniswap adapter testing", async function () {
  before(async function () {
    [this.owner] = await ethers.getSigners();
    this.amount = 1e18;
    this.swapAmount = 1e9;
    this.tokenNameA = "Token A";
    this.tokenSymbolA = "TA";
    this.tokenNameB = "Token B";
    this.tokenSymbolB = "TB";
  });
  beforeEach(async function () {
    const artifactToken: Artifact = await artifacts.readArtifact("Token");
    const artifact: Artifact = await artifacts.readArtifact("UniswapAdapter");

    this.instanceTokenA = await waffle.deployContract(
      this.owner,
      artifactToken,
      [this.tokenNameA, this.tokenSymbolA]
    );
    this.instanceTokenB = await waffle.deployContract(
      this.owner,
      artifactToken,
      [this.tokenNameB, this.tokenSymbolB]
    );
    this.instance = await waffle.deployContract(this.owner, artifact);

    await this.instanceTokenA.approve(
      this.instance.address,
      BigInt(this.amount * 2)
    );
    await this.instanceTokenB.approve(
      this.instance.address,
      BigInt(this.amount * 2)
    );
  });
  addLiquidity();
  swap();
});
