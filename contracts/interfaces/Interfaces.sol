// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.7;

interface IPoolLike {

    function manager() external view returns (address manager_);

}

interface IPoolManagerLike {

    function admin() external view returns (address admin_);

    function setActive(bool active) external;

}
