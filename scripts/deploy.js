import { network } from "hardhat";

async function main() {
    const { ethers } = await network.create();
    const Create = await ethers.getContractFactory("Create");
    const create = await Create.deploy();
    await create.waitForDeployment();
    console.log("Create deployed to:", await create.getAddress());
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});