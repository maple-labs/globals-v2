# Maple Globals V2

![Foundry CI](https://github.com/maple-labs/globals-v2/actions/workflows/push-to-main.yaml/badge.svg) [![License: AGPL v3](https://img.shields.io/badge/License-AGPL%20v3-blue.svg)](https://www.gnu.org/licenses/agpl-3.0)

## Overview

This repository holds the singleton contract `MapleGlobals` which is responsible for configuring protocol wide parameters of the Maple V2 protocol. For more information, please review the Globals section of the protocol [wiki](https://github.com/maple-labs/maple-core-v2/wiki/Globals).

## Dependencies/Inheritance

Contracts in this repo inherit and import code from:
- [`maple-labs/non-transparent-proxy`](https://github.com/maple-labs/non-transparent-proxy)

Contracts inherit and import code in the following ways:
- `Globals` inherits `NonTransparentProxied` for proxy logic.

Versions of dependencies can be checked with `git submodule status`.

## Setup

This project was built using [Foundry](https://book.getfoundry.sh/). Refer to installation instructions [here](https://github.com/foundry-rs/foundry#installation).

```sh
git clone git@github.com:maple-labs/globals-v2.git
cd globals-v2
forge install
```

## Running Tests

- To run all tests: `forge test`
- To run specific tests: `forge test --match <test_name>`

## About Maple

[Maple Finance](https://maple.finance/) is a decentralized corporate credit market. Maple provides capital to institutional borrowers through globally accessible fixed-income yield opportunities.

For all technical documentation related to the Maple V2 protocol, please refer to the GitHub [wiki](https://github.com/maple-labs/maple-core-v2/wiki).

---

<p align="center">
  <img src="https://user-images.githubusercontent.com/44272939/116272804-33e78d00-a74f-11eb-97ab-77b7e13dc663.png" height="100" />
</p>
