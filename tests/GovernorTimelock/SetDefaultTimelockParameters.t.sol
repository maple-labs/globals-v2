// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.25;

import { GovernorTimelockTestBase } from "./GovernorTimelockBase.t.sol";

contract SetDefaultTimelockParametersTests is GovernorTimelockTestBase {

    function test_setDefaultTimelockParameters_revert_notSelf() public {
        vm.expectRevert("GT:NOT_SELF");
        timelock.setDefaultTimelockParameters(1, 1);
    }

    function test_setDefaultTimelockParameters_revert_invalidDelay() public {
        uint32 minDelay           = timelock.MIN_DELAY();
        uint32 minExecutionWindow = timelock.MIN_EXECUTION_WINDOW();

        vm.expectRevert("GT:SDTP:INVALID_DELAY");
        vm.prank(address(timelock));
        timelock.setDefaultTimelockParameters(minDelay - 1, minExecutionWindow);
    }

    function test_setDefaultTimelockParameters_revert_invalidExecutionWindow() public {
        uint32 minDelay           = timelock.MIN_DELAY();
        uint32 minExecutionWindow = timelock.MIN_EXECUTION_WINDOW();

        vm.expectRevert("GT:SDTP:INVALID_EXEC_WINDOW");
        vm.prank(address(timelock));
        timelock.setDefaultTimelockParameters(minDelay, minExecutionWindow - 1);
    }

    function test_setDefaultTimelockParameters_success() public {
        ( uint32 currentDelay, uint32 currentExecutionWindow ) = timelock.defaultTimelockParameters();

        assertEq(currentDelay,           1 days);
        assertEq(currentExecutionWindow, 1 days);

        uint32 delay           = 3 days;
        uint32 executionWindow = 4 days;

        vm.expectEmit();
        emit DefaultTimelockSet(delay, executionWindow);

        vm.prank(address(timelock));
        timelock.setDefaultTimelockParameters(delay, executionWindow);

        ( currentDelay, currentExecutionWindow ) = timelock.defaultTimelockParameters();

        assertEq(currentDelay,           delay);
        assertEq(currentExecutionWindow, executionWindow);
    }

}
