// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.25;

import { MockERC20 } from "../mocks/Mocks.sol";

import { GovernorTimelockTestBase } from "./GovernorTimelockBase.t.sol";

contract WithdrawERC20TokenTests is GovernorTimelockTestBase {

    MockERC20 internal token;

    function setUp() public override {
        super.setUp();

        token = new MockERC20();
        token.mint(address(timelock), 100);
    }

    function test_withdrawERC20Token_revert_notTokenWithdrawer() public {
        vm.expectRevert("GT:WET:NOT_AUTHORIZED");
        timelock.withdrawERC20Token(address(token), 100);
    }

    function test_withdrawERC20Token_revert_transferFailed() public {
        vm.expectRevert("GT:WET:TRANSFER_FAILED");
        vm.prank(tokenWithdrawer);
        timelock.withdrawERC20Token(address(token), 101);
    }

    function test_withdrawERC20Token_success() public {
        vm.expectEmit();
        emit ERC20TokenWithdrawn(address(token), tokenWithdrawer, 100);

        vm.prank(tokenWithdrawer);
        timelock.withdrawERC20Token(address(token), 100);

        assertEq(token.balanceOf(tokenWithdrawer),   100);
        assertEq(token.balanceOf(address(timelock)), 0);
    }

}
