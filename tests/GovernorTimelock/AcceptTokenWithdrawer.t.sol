// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.25;

import { GovernorTimelockTestBase } from "./GovernorTimelockBase.t.sol";

contract AcceptTokenWithdrawerTests is GovernorTimelockTestBase {

    function test_acceptTokenWithdrawer_revert_notPendingTokenWithdrawer() public {
        address pendingTokenWithdrawer = makeAddr("pendingTokenWithdrawer");

        vm.prank(roleAdmin);
        timelock.setPendingTokenWithdrawer(pendingTokenWithdrawer);

        vm.expectRevert("GT:ATW:NOT_AUTHORIZED");
        timelock.acceptTokenWithdrawer();
    }

    function test_acceptTokenWithdrawer_success() public {
        address pendingTokenWithdrawer = makeAddr("pendingTokenWithdrawer");

        vm.prank(roleAdmin);
        timelock.setPendingTokenWithdrawer(pendingTokenWithdrawer);

        vm.expectEmit();
        emit TokenWithdrawerAccepted(pendingTokenWithdrawer);

        vm.prank(pendingTokenWithdrawer);
        timelock.acceptTokenWithdrawer();

        assertEq(timelock.tokenWithdrawer(), pendingTokenWithdrawer);
    }

}
