// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.25;

import { IGovernorTimelock } from "../../contracts/interfaces/IGovernorTimelock.sol";

import { GovernorTimelockTestBase } from "./GovernorTimelockBase.t.sol";

contract ScheduleProposalsTests is GovernorTimelockTestBase {

    function test_scheduleProposals_revert_notProposer() public {
        vm.expectRevert("GT:NOT_AUTHORIZED");
        timelock.scheduleProposals(new address[](0), new bytes[](0));
    }

    function test_scheduleProposals_revert_emptyArray() public {
        vm.expectRevert("GT:SP:EMPTY_ARRAY");
        vm.prank(proposer);
        timelock.scheduleProposals(new address[](0), new bytes[](0));
    }

    function test_scheduleProposals_revert_arrayLengthMismatch() public {
        vm.expectRevert("GT:SP:ARRAY_LENGTH_MISMATCH");
        vm.prank(proposer);
        timelock.scheduleProposals(new address[](1), new bytes[](2));
    }

    function test_scheduleProposals_revert_updateRoleNotAllowed() public {
        address[] memory targets = new address[](2);
        bytes[]   memory data    = new bytes[](2);

        targets[0] = makeAddr("target");
        targets[1] = address(timelock);

        data[0] = abi.encode(bytes4(keccak256("randomFunction")), keccak256("randomParameters"));
        data[1] = abi.encodeWithSelector(timelock.updateRole.selector, timelock.PROPOSER_ROLE(), proposer, true);

        vm.expectRevert("GT:SP:UPDATE_ROLE_NOT_ALLOWED");
        vm.prank(proposer);
        timelock.scheduleProposals(targets, data);
    }

    function test_scheduleProposals_success() public {
        address[] memory targets = new address[](2);
        bytes[]   memory data    = new bytes[](2);

        targets[0] = makeAddr("target1");
        targets[1] = makeAddr("target2");

        bytes4 functionToCall1 = bytes4(keccak256("randomFunction1"));
        bytes4 functionToCall2 = bytes4(keccak256("randomFunction2"));

        data[0] = abi.encodeWithSelector(functionToCall1, keccak256("randomParameters2"));
        data[1] = abi.encodeWithSelector(functionToCall2, keccak256("randomParameters2"));

        uint32 secondFunctionDelay           = 2 days;
        uint32 secondFunctionExecutionWindow = 2 days;

        vm.prank(address(timelock));
        timelock.setFunctionTimelockParameters(targets[1], functionToCall2, secondFunctionDelay, secondFunctionExecutionWindow);

        ( uint32 delay, uint32 executionWindow ) = timelock.defaultTimelockParameters();

        IGovernorTimelock.Proposal memory expectedProposal1 = IGovernorTimelock.Proposal({
            proposalHash:    keccak256(abi.encode(targets[0], data[0])),
            isUnschedulable: true,
            scheduledAt:     uint32(block.timestamp),
            delayedUntil:    uint32(block.timestamp) + delay,
            validUntil:      uint32(block.timestamp) + delay + executionWindow
        });

        IGovernorTimelock.Proposal memory expectedProposal2 = IGovernorTimelock.Proposal({
            proposalHash:    keccak256(abi.encode(targets[1], data[1])),
            isUnschedulable: true,
            scheduledAt:     uint32(block.timestamp),
            delayedUntil:    uint32(block.timestamp) + secondFunctionDelay,
            validUntil:      uint32(block.timestamp) + secondFunctionDelay + secondFunctionExecutionWindow
        });

        _assertEmptyProposal(1);
        _assertEmptyProposal(2);

        assertEq(timelock.latestProposalId(), 0);

        vm.expectEmit();
        emit ProposalScheduled(1, expectedProposal1);
        emit ProposalScheduled(2, expectedProposal2);

        vm.prank(proposer);
        timelock.scheduleProposals(targets, data);

        _assertProposal(1, expectedProposal1);
        _assertProposal(2, expectedProposal2);

        assertEq(timelock.latestProposalId(), 2);
    }

}
