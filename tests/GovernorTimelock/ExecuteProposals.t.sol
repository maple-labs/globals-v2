// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.25;

import { GovernorTimelockTestBase } from "./GovernorTimelockBase.t.sol";

contract ExecuteProposalsTests is GovernorTimelockTestBase {

    function test_executeProposals_revert_notExecutor() public {
        vm.expectRevert("GT:NOT_AUTHORIZED");
        timelock.executeProposals(new uint256[](0), new address[](0), new bytes[](0));
    }

    function test_executeProposals_revert_emptyArray() public {
        vm.expectRevert("GT:EP:EMPTY_ARRAY");
        vm.prank(executor);
        timelock.executeProposals(new uint256[](0), new address[](0), new bytes[](0));
    }

    function test_executeProposals_revert_invalidTargetsLength() public {
        vm.expectRevert("GT:EP:INVALID_TARGETS_LENGTH");
        vm.prank(executor);
        timelock.executeProposals(new uint256[](1), new address[](2), new bytes[](0));
    }

    function test_executeProposals_revert_invalidDataLength() public {
        vm.expectRevert("GT:EP:INVALID_DATA_LENGTH");
        vm.prank(executor);
        timelock.executeProposals(new uint256[](1), new address[](1), new bytes[](2));
    }

    function test_executeProposals_revert_notFound() public {
        uint256[] memory proposalIds = new uint256[](2);
        address[] memory targets     = new address[](2);
        bytes[]   memory data        = new bytes[](2);

        proposalIds[0] = 1;
        proposalIds[1] = 2;

        vm.expectRevert("GT:EP:PROPOSAL_NOT_FOUND");
        vm.prank(executor);
        timelock.executeProposals(proposalIds, targets, data);
    }

    function test_executeProposals_revert_notExecutable() public {
        address[] memory targets = new address[](2);
        bytes[]   memory data    = new bytes[](2);

        targets[0] = makeAddr("target1");
        targets[1] = makeAddr("target2");

        bytes4 functionToCall1 = bytes4(keccak256("randomFunction1"));
        bytes4 functionToCall2 = bytes4(keccak256("randomFunction2"));

        data[0] = abi.encodeWithSelector(functionToCall1, abi.encode(keccak256("randomParameters1")));
        data[1] = abi.encodeWithSelector(functionToCall2, abi.encode(keccak256("randomParameters2")));

        ( uint32 delay, uint32 executionWindow ) = timelock.defaultTimelockParameters();

        vm.prank(address(timelock));
        timelock.setFunctionTimelockParameters(targets[1], functionToCall2, 2 * delay, 2 * executionWindow);

        vm.prank(proposer);
        timelock.scheduleProposals(targets, data);

        uint256 startingTimestamp = block.timestamp;

        vm.warp(startingTimestamp + delay);

        uint256[] memory proposalIds = new uint256[](2);
        proposalIds[0]               = 1;
        proposalIds[1]               = 2;

        assertEq(timelock.isExecutable(1), true);
        assertEq(timelock.isExecutable(2), false);

        vm.expectRevert("GT:EP:NOT_EXECUTABLE");
        vm.prank(executor);
        timelock.executeProposals(proposalIds, targets, data);

        vm.warp(startingTimestamp + 2 * delay + executionWindow + 1);

        vm.expectRevert("GT:EP:NOT_EXECUTABLE");
        vm.prank(executor);
        timelock.executeProposals(proposalIds, targets, data);

        assertEq(timelock.isExecutable(1), false);
        assertEq(timelock.isExecutable(2), true);
    }

    function test_executeProposals_revert_invalidData() public {
        address[] memory targets = new address[](2);
        bytes[]   memory data    = new bytes[](2);

        targets[0] = makeAddr("target1");
        targets[1] = makeAddr("target2");

        bytes4 functionToCall1 = bytes4(keccak256("randomFunction1"));
        bytes4 functionToCall2 = bytes4(keccak256("randomFunction2"));

        data[0] = abi.encode(functionToCall1, keccak256("randomParameters1"));
        data[1] = abi.encode(functionToCall2, keccak256("randomParameters2"));

        ( uint32 delay, ) = timelock.defaultTimelockParameters();

        vm.prank(proposer);
        timelock.scheduleProposals(targets, data);

        vm.warp(block.timestamp + delay);

        uint256[] memory proposalIds = new uint256[](2);
        proposalIds[0]               = 1;
        proposalIds[1]               = 2;

        data[1] = abi.encode(keccak256("randomInvalidParameters"));

        vm.expectRevert("GT:EP:INVALID_DATA");
        vm.prank(executor);
        timelock.executeProposals(proposalIds, targets, data);

        assertEq(timelock.isExecutable(1), true);
        assertEq(timelock.isExecutable(2), true);
    }

    function test_executeProposals_executionFailed() public {
        address[] memory targets = new address[](2);
        bytes[]   memory data    = new bytes[](2);

        targets[0] = makeAddr("target1");
        targets[1] = makeAddr("target2");

        bytes4 functionToCall1 = bytes4(keccak256("randomFunction1"));
        bytes4 functionToCall2 = bytes4(keccak256("randomFunction2"));

        bytes memory randomParameters1 = abi.encode(keccak256("randomParameters1"));
        bytes memory randomParameters2 = abi.encode(keccak256("randomParameters2"));

        data[0] = abi.encode(functionToCall1, randomParameters1);
        data[1] = abi.encode(functionToCall2, randomParameters2);

        vm.prank(proposer);
        timelock.scheduleProposals(targets, data);

        ( uint32 delay, ) = timelock.defaultTimelockParameters();

        vm.warp(block.timestamp + delay);

        vm.mockCallRevert(targets[0], abi.encode(functionToCall1, randomParameters1), abi.encode(false));

        uint256[] memory proposalIds = new uint256[](2);
        proposalIds[0]               = 1;
        proposalIds[1]               = 2;

        vm.expectRevert("GT:EP:FAILED");
        vm.prank(executor);
        timelock.executeProposals(proposalIds, targets, data);

        assertEq(timelock.isExecutable(1), true);
        assertEq(timelock.isExecutable(2), true);
    }

    function test_executeProposals_success() public {
        address[] memory targets = new address[](2);
        bytes[]   memory data    = new bytes[](2);

        targets[0] = makeAddr("target1");
        targets[1] = makeAddr("target2");

        bytes4 functionToCall1 = bytes4(keccak256("randomFunction1"));
        bytes4 functionToCall2 = bytes4(keccak256("randomFunction2"));

        bytes memory randomParameters1 = abi.encode(keccak256("randomParameters1"));
        bytes memory randomParameters2 = abi.encode(keccak256("randomParameters2"));

        data[0] = abi.encodeWithSelector(functionToCall1, randomParameters1);
        data[1] = abi.encodeWithSelector(functionToCall2, randomParameters2);

        vm.prank(proposer);
        timelock.scheduleProposals(targets, data);

        _assertNotEmptyProposal(1);
        _assertNotEmptyProposal(2);

        assertEq(timelock.latestProposalId(), 2);

        ( uint32 delay, ) = timelock.defaultTimelockParameters();

        vm.warp(block.timestamp + delay);

        vm.mockCall(targets[0], abi.encodeWithSelector(functionToCall1, randomParameters1), abi.encode(true));
        vm.mockCall(targets[1], abi.encodeWithSelector(functionToCall2, randomParameters2), abi.encode(true));

        uint256[] memory proposalIds = new uint256[](2);
        proposalIds[0]               = 1;
        proposalIds[1]               = 2;

        assertEq(timelock.isExecutable(1), true);
        assertEq(timelock.isExecutable(2), true);

        vm.expectEmit();
        emit ProposalExecuted(proposalIds[0]);
        emit ProposalExecuted(proposalIds[1]);

        vm.prank(executor);
        timelock.executeProposals(proposalIds, targets, data);

        _assertEmptyProposal(1);
        _assertEmptyProposal(2);

        assertEq(timelock.latestProposalId(), 2);

        assertEq(timelock.isExecutable(1), false);
        assertEq(timelock.isExecutable(2), false);
    }

}
