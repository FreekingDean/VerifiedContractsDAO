// This is a script for deploying your contracts. You can adapt it to deploy
// yours, or create new ones.

const path = require("path");

async function main() {
  // This is just a convenience check
  if (network.name === "hardhat") {
    console.warn(
      "You are trying to deploy a contract to the Hardhat Network, which" +
        "gets automatically created and destroyed every time. Use the Hardhat" +
        " option '--network localhost'"
    );
  }

  // ethers is available in the global scope
  const [deployer] = await ethers.getSigners();
  console.log(
    "Deploying the contracts with the account:",
    await deployer.getAddress()
  );

  console.log("Account balance:", (await deployer.getBalance()).toString());

  const Token = await ethers.getContractFactory("VCToken");
  const token = await Token.deploy();
  await token.deployed();

  const TimelockAddress = '0x36A373B51CB42eA098A2e63Bae5D6Fd8c8A7E211';
  const TimelockController = await ethers.getContractFactory('contracts/TimelockController.sol:TimelockController');
  const timelockController = await TimelockController.attach(TimelockAddress);
  const Governor = await ethers.getContractFactory("VCTGovernor");
  const governor = await Governor.deploy(token.address, timelockController.address);
  await governor.deployed();

  console.log("Token address:", token.address);
  console.log("Governor address:", governor.address);

  // We also save the contract's artifacts and address in the frontend directory
  saveFrontendFiles(token, governor);
}

function saveFrontendFiles(token, governor) {
  const fs = require("fs");
  const contractsDir = path.join(__dirname, "..", "frontend", "src", "contracts");

  if (!fs.existsSync(contractsDir)) {
    fs.mkdirSync(contractsDir);
  }

  fs.writeFileSync(
    path.join(contractsDir, "contract-address.json"),
    JSON.stringify({ Token: token.address, Governor: governor.address }, undefined, 2)
  );

  const TokenArtifact = artifacts.readArtifactSync("VCToken");
  const GovernorArtifact = artifacts.readArtifactSync("VCTGovernor");

  fs.writeFileSync(
    path.join(contractsDir, "Token.json"),
    JSON.stringify(TokenArtifact, null, 2)
  );
  fs.writeFileSync(
    path.join(contractsDir, "Governor.json"),
    JSON.stringify(GovernorArtifact, null, 2)
  );
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
