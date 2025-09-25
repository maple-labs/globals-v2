// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.25;

import { GovernorTimelockTestBase } from "./GovernorTimelockBase.t.sol";

contract SetFunctionTimelockParametersTests is GovernorTimelockTestBase {

    function test_setFunctionTimelockParameters_revert_notSelf() public {
        address target           = makeAddr("target");
        bytes4  functionSelector = bytes4(keccak256("randomFunction()"));

        vm.expectRevert("GT:NOT_SELF");
        timelock.setFunctionTimelockParameters(target, functionSelector, 1, 1);
    }

    function test_setFunctionTimelockParameters_revert_invalidDefaultForDelay() public {
        uint32 delay           = 0;
        uint32 executionWindow = 1 seconds;

        address target           = makeAddr("target");
        bytes4  functionSelector = bytes4(keccak256("randomFunction()"));

        vm.expectRevert("GT:SFTP:INVALID_PARAMETERS");
        vm.prank(address(timelock));
        timelock.setFunctionTimelockParameters(target, functionSelector, delay, executionWindow);
    }

    function test_setFunctionTimelockParameters_revert_invalidDefaultForExecutionWindow() public {
        uint32 delay           = 1 seconds;
        uint32 executionWindow = 0;

        address target           = makeAddr("target");
        bytes4  functionSelector = bytes4(keccak256("randomFunction()"));

        vm.expectRevert("GT:SFTP:INVALID_PARAMETERS");
        vm.prank(address(timelock));
        timelock.setFunctionTimelockParameters(target, functionSelector, delay, executionWindow);
    }

    function test_setFunctionTimelockParameters_revert_invalidDelay() public {
        uint32 minDelay           = timelock.MIN_DELAY();
        uint32 minExecutionWindow = timelock.MIN_EXECUTION_WINDOW();

        address target           = makeAddr("target");
        bytes4  functionSelector = bytes4(keccak256("randomFunction()"));

        vm.expectRevert("GT:SFTP:INVALID_PARAMETERS");
        vm.prank(address(timelock));
        timelock.setFunctionTimelockParameters(target, functionSelector, minDelay - 1, minExecutionWindow);
    }

    function test_setFunctionTimelockParameters_revert_invalidExecutionWindow() public {
        uint32 minDelay           = timelock.MIN_DELAY();
        uint32 minExecutionWindow = timelock.MIN_EXECUTION_WINDOW();

        address target           = makeAddr("target");
        bytes4  functionSelector = bytes4(keccak256("randomFunction()"));

        vm.expectRevert("GT:SFTP:INVALID_PARAMETERS");
        vm.prank(address(timelock));
        timelock.setFunctionTimelockParameters(target, functionSelector, minDelay, minExecutionWindow - 1);
    }

    function test_setFunctionTimelockParameters_success() public {
        address target           = makeAddr("target");
        bytes4  functionSelector = bytes4(keccak256("randomFunction()"));

        ( uint32 currentDelay, uint32 currentExecutionWindow ) = timelock.functionTimelockParameters(target, functionSelector);

        assertEq(currentDelay,           0);
        assertEq(currentExecutionWindow, 0);

        uint32 delay           = 3 days;
        uint32 executionWindow = 4 days;

        vm.expectEmit();
        emit FunctionTimelockSet(target, functionSelector, delay, executionWindow);

        vm.prank(address(timelock));
        timelock.setFunctionTimelockParameters(target, functionSelector, delay, executionWindow);

        ( currentDelay, currentExecutionWindow ) = timelock.functionTimelockParameters(target, functionSelector);

        assertEq(currentDelay,           delay);
        assertEq(currentExecutionWindow, executionWindow);
    }

    function test_setFunctionTimelockParameters_resetToDefaults_success() public {
        address target           = makeAddr("target");
        bytes4  functionSelector = bytes4(keccak256("randomFunction()"));

        ( uint32 currentDelay, uint32 currentExecutionWindow ) = timelock.functionTimelockParameters(target, functionSelector);

        assertEq(currentDelay,           0);
        assertEq(currentExecutionWindow, 0);

        uint32 delay           = 3 days;
        uint32 executionWindow = 4 days;

        vm.expectEmit();
        emit FunctionTimelockSet(target, functionSelector, delay, executionWindow);

        vm.prank(address(timelock));
        timelock.setFunctionTimelockParameters(target, functionSelector, delay, executionWindow);

        ( currentDelay, currentExecutionWindow ) = timelock.functionTimelockParameters(target, functionSelector);

        assertEq(currentDelay,           delay);
        assertEq(currentExecutionWindow, executionWindow);

        delay           = 0;
        executionWindow = 0;

        vm.expectEmit();
        emit FunctionTimelockSet(target, functionSelector, delay, executionWindow);

        vm.prank(address(timelock));
        timelock.setFunctionTimelockParameters(target, functionSelector, delay, executionWindow);

        ( currentDelay, currentExecutionWindow ) = timelock.functionTimelockParameters(target, functionSelector);

        assertEq(currentDelay,           0);
        assertEq(currentExecutionWindow, 0);
    }

}
