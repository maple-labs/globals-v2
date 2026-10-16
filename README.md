# Maple Globals V2

![Foundry CI](https://github.com/maple-labs/globals-v2/actions/workflows/ci.yaml/badge.svg)
[![GitBook - Documentation](https://img.shields.io/badge/GitBook-Documentation-orange?logo=gitbook&logoColor=white)](https://maplefinance.gitbook.io/maple/technical-resources/protocol-overview)
[![Foundry][foundry-badge]][foundry]
[![License: BUSL 1.1](https://img.shields.io/badge/License-BUSL%201.1-blue.svg)](https://github.com/maple-labs/globals-v2/blob/main/LICENSE)

[foundry]: https://getfoundry.sh/
[foundry-badge]: https://img.shields.io/badge/Built%20with-Foundry-FFDB1C.svg

## Overview

This repository holds the singleton contract `MapleGlobals` which is responsible for configuring protocol wide parameters of the Maple V2 protocol, and the `GovernorTimelock` contract which schedules and executes governance proposals after a timelock.

## Dependencies/Inheritance

Contracts in this repo inherit and import code from:
- [`maple-labs/erc20-helper`](https://github.com/maple-labs/erc20-helper)
- [`maple-labs/non-transparent-proxy`](https://github.com/maple-labs/non-transparent-proxy)

Contracts inherit and import code in the following ways:
- `MapleGlobals` inherits `NonTransparentProxied` for proxy logic.
- `GovernorTimelock` uses `ERC20Helper` for token interactions.

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

`./scripts/test.sh` is used to enable Foundry profile usage with the `-p` flag. Profiles are used to specify the number of fuzz runs.

## Bug Bounty

For all information related to the ongoing bug bounty for these contracts run by [Immunefi](https://immunefi.com/), please visit this [site](https://immunefi.com/bounty/maple/).

## About Maple

[Maple Finance](https://maple.finance/) is a decentralized corporate credit market. Maple provides capital to institutional borrowers through globally accessible fixed-income yield opportunities.

---

<p align="center">
  <img src="https://github.com/maple-labs/maple-metadata/blob/796e313f3b2fd4960929910cd09a9716688a4410/assets/maplelogo.png" height="100" />
</p>
