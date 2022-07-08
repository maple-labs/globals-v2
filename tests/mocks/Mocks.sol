// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.7;

contract MockPool {

    address public manager;

    constructor(address manager_) {
        manager = manager_;
    }

}

contract MockPoolManager {

    address public admin;

    constructor(address admin_) {
        admin = admin_;
    }

    function setActive(bool active_) external { }

}
