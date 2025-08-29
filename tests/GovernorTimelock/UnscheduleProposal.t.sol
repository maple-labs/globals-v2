// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.25;

import { MockTarget } from "../mocks/Mocks.sol";

import { GovernorTimelockTestBase } from "./GovernorTimelockBase.t.sol";

contract UnscheduleProposalsTests is GovernorTimelockTestBase {

    function test_unscheduleProposals_revert_notCanceller() public {
        vm.expectRevert("GT:NOT_AUTHORIZED");
        timelock.unscheduleProposals(new uint256[](0));
    }

    function test_unscheduleProposals_revert_proposalNotFound() public {
        vm.prank(canceler);
        vm.expectRevert("GT:UP:PROPOSAL_NOT_FOUND");
        timelock.unscheduleProposals(new uint256[](1));
    }

    function test_unscheduleProposals_revert_notUnschedulable() public {
        bytes32[] memory roles       = new bytes32[](2);
        address[] memory accounts    = new address[](2);
        bool[]    memory shouldGrant = new bool[](2);

        roles[0] = keccak256("randomRole1");
        roles[1] = keccak256("randomRole2");

        accounts[0] = makeAddr("account1");
        accounts[1] = makeAddr("account2");

        shouldGrant[0] = true;
        shouldGrant[1] = false;

        vm.prank(roleAdmin);
        timelock.proposeRoleUpdates(roles, accounts, shouldGrant);

        _assertNotEmptyProposal(1);
        _assertNotEmptyProposal(2);

        uint256[] memory proposalIds = new uint256[](1);
        proposalIds[0]               = 1;

        vm.expectRevert("GT:UP:NOT_UNSCHEDULABLE");
        vm.prank(canceler);
        timelock.unscheduleProposals(proposalIds);

        proposalIds[0] = 2;

        vm.expectRevert("GT:UP:NOT_UNSCHEDULABLE");
        vm.prank(canceler);
        timelock.unscheduleProposals(proposalIds);
    }

    function test_unscheduleProposals_success() public {
        address[] memory targets = new address[](2);
        bytes[]   memory data    = new bytes[](2);

        targets[0] = address(new MockTarget());
        targets[1] = address(new MockTarget());

        bytes4 functionToCall1 = bytes4(keccak256("randomFunction(bytes)"));
        bytes4 functionToCall2 = bytes4(keccak256("randomFunction(bytes)"));

        data[0] = abi.encodeWithSelector(functionToCall1, "randomParameters1");
        data[1] = abi.encodeWithSelector(functionToCall2, "randomParameters2");

        vm.prank(proposer);
        timelock.scheduleProposals(targets, data);

        _assertNotEmptyProposal(1);
        _assertNotEmptyProposal(2);

        assertEq(timelock.latestProposalId(), 2);

        uint256[] memory proposalIds = new uint256[](2);

        proposalIds[0] = 1;
        proposalIds[1] = 2;

        vm.expectEmit();
        emit ProposalUnscheduled(1);
        emit ProposalUnscheduled(2);

        vm.prank(canceler);
        timelock.unscheduleProposals(proposalIds);

        _assertEmptyProposal(1);
        _assertEmptyProposal(2);

        assertEq(timelock.latestProposalId(), 2);
    }

}
