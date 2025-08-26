// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.25;

import { GovernorTimelockTestBase } from "./GovernorTimelockBase.t.sol";

contract UpdateRoleTests is GovernorTimelockTestBase {

    function test_updateRole_revert_notSelf() public {
        vm.expectRevert("GT:NOT_SELF");
        timelock.updateRole(bytes32(0), makeAddr("account"), true);
    }

    function test_updateRole_success() public {
        bytes32 role    = bytes32(keccak256("role"));
        address account = makeAddr("account");

        assertEq(timelock.hasRole(account, role), false);

        vm.expectEmit();
        emit RoleUpdated(role, account, true);

        vm.prank(address(timelock));
        timelock.updateRole(role, account, true);

        assertEq(timelock.hasRole(account, role), true);

        vm.expectEmit();
        emit RoleUpdated(role, account, false);

        vm.prank(address(timelock));
        timelock.updateRole(role, account, false);

        assertEq(timelock.hasRole(account, role), false);
    }

}
