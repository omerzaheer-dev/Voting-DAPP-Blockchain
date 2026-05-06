import hre from "hardhat";


async function main() {
    const Create = await hre.ethers.getContractFactory("Create");
    const create = await Create.deploy();
    await create.waitForDeployment();

}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});