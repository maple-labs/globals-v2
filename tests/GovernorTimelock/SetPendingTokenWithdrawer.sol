// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.25;

import { GovernorTimelockTestBase } from "./GovernorTimelockBase.t.sol";

contract SetPendingTokenWithdrawerTests is GovernorTimelockTestBase {

    function test_setPendingTokenWithdrawer_revert_notTokenWithdrawer() public {
        vm.expectRevert("GT:SPTW:NOT_AUTHORIZED");
        timelock.setPendingTokenWithdrawer(makeAddr("pendingTokenWithdrawer"));
    }

    function test_setPendingTokenWithdrawer_success() public {
        address pendingTokenWithdrawer = makeAddr("pendingTokenWithdrawer");

        vm.expectEmit();
        emit PendingTokenWithdrawerSet(pendingTokenWithdrawer);

        vm.prank(tokenWithdrawer);
        timelock.setPendingTokenWithdrawer(pendingTokenWithdrawer);

        assertEq(timelock.pendingTokenWithdrawer(), pendingTokenWithdrawer);
        assertEq(timelock.tokenWithdrawer(),        tokenWithdrawer);
    }

}
