// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.7;

import { Test } from "../../modules/forge-std/src/Test.sol";

import { IGovernorTimelock } from "../../contracts/interfaces/IGovernorTimelock.sol";

import { GovernorTimelock } from "../../contracts/GovernorTimelock.sol";

contract GovernorTimelockTestBase is Test {

    event DefaultTimelockSet(uint32 delay, uint32 executionWindow);
    event ERC20TokenWithdrawn(address indexed token, address indexed tokenWithdrawer, uint256 amount);
    event FunctionTimelockSet(address indexed target, bytes4 indexed functionSelector, uint32 delay, uint32 executionWindow);
    event PendingTokenWithdrawerSet(address indexed newPendingTokenWithdrawer);
    event ProposalExecuted(uint256 indexed proposalId);
    event ProposalScheduled(uint256 indexed proposalId, IGovernorTimelock.Proposal proposal);
    event ProposalUnscheduled(uint256 indexed proposalId);
    event RoleUpdated(bytes32 indexed role, address indexed account, bool grantRole);
    event TokenWithdrawerAccepted(address indexed tokenWithdrawer);

    address internal canceler        = makeAddr("canceler");
    address internal executor        = makeAddr("executor");
    address internal proposer        = makeAddr("proposer");
    address internal roleAdmin       = makeAddr("roleAdmin");
    address internal tokenWithdrawer = makeAddr("tokenWithdrawer");

    GovernorTimelock internal timelock;

    function setUp() public virtual {
        timelock = new GovernorTimelock(tokenWithdrawer, proposer, executor, canceler, roleAdmin);
    }

    function test_deployment() public {
        assertEq(timelock.tokenWithdrawer(), tokenWithdrawer);

        ( uint32 delay, uint32 executionWindow ) = timelock.defaultTimelockParameters();
        assertEq(delay,           timelock.MIN_DELAY());
        assertEq(executionWindow, timelock.MIN_EXECUTION_WINDOW());

        assertEq(timelock.hasRole(proposer,  timelock.PROPOSER_ROLE()),  true);
        assertEq(timelock.hasRole(canceler,  timelock.CANCELLER_ROLE()), true);
        assertEq(timelock.hasRole(executor,  timelock.EXECUTOR_ROLE()),  true);
        assertEq(timelock.hasRole(roleAdmin, timelock.ROLE_ADMIN()),     true);
    }

    function _assertProposal(uint256 proposalId, IGovernorTimelock.Proposal memory proposal) internal {
        (
            bytes32 proposalHash,
            bool    isUnschedulable,
            uint32  scheduledAt,
            uint32  delayedUntil,
            uint32  validUntil
        ) = timelock.proposals(proposalId);

        assertEq(proposalHash,    proposal.proposalHash);
        assertEq(isUnschedulable, proposal.isUnschedulable);
        assertEq(scheduledAt,     proposal.scheduledAt);
        assertEq(delayedUntil,    proposal.delayedUntil);
        assertEq(validUntil,      proposal.validUntil);
    }

    function _assertEmptyProposal(uint256 proposalId) internal {
        (
            bytes32 proposalHash,
            bool    isUnschedulable,
            uint32  scheduledAt,
            uint32  delayedUntil,
            uint32  validUntil
        ) = timelock.proposals(proposalId);

        assertEq(proposalHash,    bytes32(0));
        assertEq(isUnschedulable, false);
        assertEq(scheduledAt,     0);
        assertEq(delayedUntil ,   0);
        assertEq(validUntil,      0);
    }

    function _assertNotEmptyProposal(uint256 proposalId) internal {
        ( bytes32 proposalHash, , uint32 scheduledAt, uint32 delayedUntil, uint32 validUntil ) = timelock.proposals(proposalId);

        assertNotEq(proposalHash, bytes32(0));
        assertNotEq(scheduledAt,  uint32(0));
        assertNotEq(delayedUntil, uint32(0));
        assertNotEq(validUntil,   uint32(0));
    }

}
