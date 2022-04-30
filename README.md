# omniscient • [![tests](https://github.com/zksoju/omniscient/actions/workflows/tests.yml/badge.svg)](https://github.com/zksoju/omniscient/actions/workflows/tests.yml) [![lints](https://github.com/zksoju/omniscient/actions/workflows/lints.yml/badge.svg)](https://github.com/zksoju/omniscient/actions/workflows/lints.yml) ![GitHub](https://img.shields.io/github/license/zksoju/omniscient) ![GitHub package.json version](https://img.shields.io/github/package-json/v/zksoju/omniscient)

Interactible Cross-chain ERC721 Implementation

## Overview

`Omniscient` is deployed on Rinkeby at [`0x683f4aa38232aebc69f117a9250b7eb65796426d`](https://rinkeby.etherscan.io/address/0x683f4aa38232aebc69f117a9250b7eb65796426d)

`Everest` is deployed on Fuji at [`0x11077f362979edc844549cf86dfdf28c7cc77cfb`](https://testnet.snowtrace.io/address/0x11077f362979edc844549cf86dfdf28c7cc77cfb)

## Blueprint

```ml
lib
├─ forge-std — https://github.com/brockelmore/forge-std
├─ LayerZero — https://github.com/LayerZero-Labs/LayerZero
├─ openzeppelin-contracts — https://github.com/openzeppelin-contracts
├─ solmate — https://github.com/Rari-Capital/solmate
src
├─ lzApp
│  └─ LzApp — Standard template contract for interacting with LayerZero messaging protocol
│  └─ NonblockingLzApp — Non-blocking implementation of LzApp
├─ tests
│  └─ ...
└─ Omniscient — ERC721 Contract that listens for LayerZero messages
└─ Everest — Omniscient ownership manager contract that lives on a different chain
```

## Development

**Setup**

```bash
make
# OR #
make setup
```

**Building**

```bash
make build
```

**Testing**

```bash
make test
```

**Deployment & Verification**

Inside the [`scripts/`](./scripts/) directory are a few preconfigured scripts that can be used to deploy and verify contracts.

Scripts take inputs from the cli, using silent mode to hide any sensitive information.

NOTE: These scripts are required to be _executable_ meaning they must be made executable by running `chmod +x ./scripts/*`.

NOTE: For local deployment, make sure to run `yarn` or `npm install` before running the `deploy_local.sh` script. Otherwise, hardhat will error due to missing dependencies.

NOTE: these scripts will prompt you for the contract name and deployed addresses (when verifying). Also, they use the `-i` flag on `forge` to ask for your private key for deployment. This uses silent mode which keeps your private key from being printed to the console (and visible in logs).

### First time with Forge/Foundry?

See the official Foundry installation [instructions](https://github.com/gakonst/foundry/blob/master/README.md#installation).

Then, install the [foundry](https://github.com/gakonst/foundry) toolchain installer (`foundryup`) with:

```bash
curl -L https://foundry.paradigm.xyz | bash
```

Now that you've installed the `foundryup` binary,
anytime you need to get the latest `forge` or `cast` binaries,
you can run `foundryup`.

So, simply execute:

```bash
foundryup
```

🎉 Foundry is installed! 🎉

### Writing Tests with Foundry

With [Foundry](https://gakonst.xyz), tests are written in Solidity! 🥳

Create a test file for your contract in the `src/tests/` directory.

For example, [`src/Greeter.sol`](./src/Greeter.sol) has its test file defined in [`./src/tests/Greeter.t.sol`](./src/tests/Greeter.t.sol).

To learn more about writing tests in Solidity for Foundry, reference Rari Capital's [solmate](https://github.com/Rari-Capital/solmate/tree/main/src/test) repository created by [@transmissions11](https://twitter.com/transmissions11).

### Configure Foundry

Using [foundry.toml](./foundry.toml), Foundry is easily configurable.

For a full list of configuration options, see the Foundry [configuration documentation](https://github.com/gakonst/foundry/blob/master/config/README.md#all-options).

## License

[AGPL-3.0-only](https://github.com/abigger87/femplate/blob/master/LICENSE)

## Acknowledgements

-   [femplate](https://github.com/abigger87/femplate)
-   [foundry](https://github.com/gakonst/foundry)
-   [solmate](https://github.com/Rari-Capital/solmate)
-   [forge-std](https://github.com/brockelmore/forge-std)
-   [clones-with-immutable-args](https://github.com/wighawag/clones-with-immutable-args).
-   [foundry-toolchain](https://github.com/onbjerg/foundry-toolchain) by [onbjerg](https://github.com/onbjerg).
-   [forge-template](https://github.com/FrankieIsLost/forge-template) by [FrankieIsLost](https://github.com/FrankieIsLost).
-   [Georgios Konstantopoulos](https://github.com/gakonst) for [forge-template](https://github.com/gakonst/forge-template) resource.

## Disclaimer

_These smart contracts are being provided as is. No guarantee, representation or warranty is being made, express or implied, as to the safety or correctness of the user interface or the smart contracts. They have not been audited and as such there can be no assurance they will work as intended, and users may experience delays, failures, errors, omissions, loss of transmitted information or loss of funds. The creators are not liable for any of the foregoing. Users should proceed with caution and use at their own risk._
