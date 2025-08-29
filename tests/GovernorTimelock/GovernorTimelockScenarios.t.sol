// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.25;

import { MockERC20 } from "../mocks/Mocks.sol";

import { GovernorTimelockTestBase } from "./GovernorTimelockBase.t.sol";

contract GovernorTimelockScenariosTests is GovernorTimelockTestBase {

    function test_updateTimelockConfig_success_fullProposalCycle() public {
        ( uint32 delay, ) = timelock.defaultTimelockParameters();

        address[] memory targets = new address[](2);
        bytes[]   memory data    = new bytes[](2);

        targets[0] = address(timelock);
        targets[1] = address(timelock);

        data[0] = abi.encodeWithSelector(timelock.setDefaultTimelockParameters.selector, 2 days, 2 days);
        data[1] = abi.encodeWithSelector(
            timelock.setFunctionTimelockParameters.selector,
            address(timelock),
            timelock.setFunctionTimelockParameters.selector,
            3 days,
            3 days
        );

        vm.prank(proposer);
        timelock.scheduleProposals(targets, data);

        vm.warp(block.timestamp + delay);

        uint256[] memory proposalIds = new uint256[](2);
        proposalIds[0]               = 1;
        proposalIds[1]               = 2;

        vm.prank(executor);
        timelock.executeProposals(proposalIds, targets, data);

        ( uint32 newDelay, uint32 newExecutionWindow ) = timelock.defaultTimelockParameters();

        assertEq(newDelay,           2 days);
        assertEq(newExecutionWindow, 2 days);

        ( newDelay, newExecutionWindow ) =
            timelock.functionTimelockParameters(address(timelock), timelock.setFunctionTimelockParameters.selector);

        assertEq(newDelay,           3 days);
        assertEq(newExecutionWindow, 3 days);
    }

    function test_executeProposals_revert_unscheduledProposal() public {
        ( uint32 delay, ) = timelock.defaultTimelockParameters();

        address[] memory targets = new address[](1);
        bytes[]   memory data    = new bytes[](1);

        targets[0] = address(timelock);
        data[0]    = abi.encodeWithSelector(timelock.setDefaultTimelockParameters.selector, 2 days, 2 days);

        vm.prank(proposer);
        timelock.scheduleProposals(targets, data);

        uint256[] memory proposalIds = new uint256[](1);

        proposalIds[0] = 1;

        vm.prank(canceler);
        timelock.unscheduleProposals(proposalIds);

        vm.warp(block.timestamp + delay);

        vm.prank(executor);
        vm.expectRevert("GT:EP:PROPOSAL_NOT_FOUND");
        timelock.executeProposals(proposalIds, targets, data);

        _assertEmptyProposal(1);

        assertEq(timelock.latestProposalId(), 1);
        assertEq(timelock.isExecutable(1),    false);
    }

    function test_proposeRoleUpdates_unsuccessfulUnschedule() public {
        ( uint32 delay, ) = timelock.defaultTimelockParameters();

        bytes32[] memory roles    = new bytes32[](1);
        address[] memory accounts = new address[](1);
        bool[] memory shouldGrant = new bool[](1);

        roles[0]       = timelock.PROPOSER_ROLE();
        accounts[0]    = proposer;
        shouldGrant[0] = false;

        vm.prank(roleAdmin);
        timelock.proposeRoleUpdates(roles, accounts, shouldGrant);

        vm.warp(block.timestamp + delay);

        uint256[] memory proposalIds = new uint256[](1);
        proposalIds[0]               = 1;

        vm.expectRevert("GT:UP:NOT_UNSCHEDULABLE");
        vm.prank(canceler);
        timelock.unscheduleProposals(proposalIds);

        address[] memory targets = new address[](1);
        bytes[]   memory data    = new bytes[](1);

        targets[0] = address(timelock);
        data[0]    = abi.encodeWithSelector(timelock.updateRole.selector, roles[0], accounts[0], shouldGrant[0]);

        assertEq(timelock.hasRole(proposer, timelock.PROPOSER_ROLE()), true);

        vm.prank(executor);
        timelock.executeProposals(proposalIds, targets, data);

        assertEq(timelock.hasRole(proposer, timelock.PROPOSER_ROLE()), false);
    }

    function test_setFunctionTimelockParameters_respectsDelayOfFunction() public {
        ( uint32 delay, ) = timelock.defaultTimelockParameters();

        MockERC20 token = new MockERC20();

        address[] memory targets = new address[](1);
        bytes[]   memory data    = new bytes[](1);

        targets[0] = address(timelock);
        data[0]    = abi.encodeWithSelector(
            timelock.setFunctionTimelockParameters.selector,
            address(token),
            token.transfer.selector,
            5 days,
            5 days
        );

        vm.prank(proposer);
        timelock.scheduleProposals(targets, data);

        uint256[] memory proposalIds = new uint256[](1);
        proposalIds[0]               = 1;

        vm.warp(block.timestamp + delay);
        vm.prank(executor);
        timelock.executeProposals(proposalIds, targets, data);

        ( uint32 newDelay, uint32 newExecutionWindow ) = timelock.functionTimelockParameters(address(token), token.transfer.selector);

        assertEq(newDelay,           5 days);
        assertEq(newExecutionWindow, 5 days);

        data[0] = abi.encodeWithSelector(
            timelock.setFunctionTimelockParameters.selector,
            address(token),
            token.transfer.selector,
            1 days,
            1 days
        );

        vm.prank(proposer);
        timelock.scheduleProposals(targets, data);

        proposalIds[0] = 2;
        vm.warp(block.timestamp + delay);

        vm.expectRevert("GT:EP:NOT_EXECUTABLE");
        vm.prank(executor);
        timelock.executeProposals(proposalIds, targets, data);

        vm.warp(block.timestamp + 4 days);
        vm.prank(executor);
        timelock.executeProposals(proposalIds, targets, data);

        ( newDelay, newExecutionWindow ) = timelock.functionTimelockParameters(address(token), token.transfer.selector);

        assertEq(newDelay,           1 days);
        assertEq(newExecutionWindow, 1 days);
    }

}
