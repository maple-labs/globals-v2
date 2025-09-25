// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.25;

import { ERC20Helper } from "../modules/erc20-helper/src/ERC20Helper.sol";

import { IGovernorTimelock } from "./interfaces/IGovernorTimelock.sol";

contract GovernorTimelock is IGovernorTimelock {

    /**************************************************************************************************************************************/
    /*** Storage                                                                                                                        ***/
    /**************************************************************************************************************************************/

    bytes32 public override constant PROPOSER_ROLE  = keccak256("PROPOSER_ROLE");
    bytes32 public override constant EXECUTOR_ROLE  = keccak256("EXECUTOR_ROLE");
    bytes32 public override constant CANCELLER_ROLE = keccak256("CANCELLER_ROLE");
    bytes32 public override constant ROLE_ADMIN     = keccak256("ROLE_ADMIN");

    uint32 public override constant MIN_DELAY            = 1 days;
    uint32 public override constant MIN_EXECUTION_WINDOW = 1 days;

    address public override pendingTokenWithdrawer;
    address public override tokenWithdrawer;

    uint256 public override latestProposalId;

    TimelockParameters public override defaultTimelockParameters;

    mapping(uint256 => Proposal) public override proposals;

    mapping(address => mapping(bytes32 => bool)) public override hasRole;

    mapping(address => mapping(bytes4 => TimelockParameters)) public override functionTimelockParameters;

    /**************************************************************************************************************************************/
    /*** Modifiers                                                                                                                      ***/
    /**************************************************************************************************************************************/

    modifier onlyRole(bytes32 role_) {
        require(hasRole[msg.sender][role_], "GT:NOT_AUTHORIZED");

        _;
    }

    modifier onlySelf() {
        require(msg.sender == address(this), "GT:NOT_SELF");

        _;
    }

    /**************************************************************************************************************************************/
    /*** Constructor                                                                                                                    ***/
    /**************************************************************************************************************************************/

    constructor(address tokenWithdrawer_, address proposer_, address executor_, address canceller_, address roleAdmin_) {
        tokenWithdrawer           = tokenWithdrawer_;
        defaultTimelockParameters = TimelockParameters({ delay: MIN_DELAY, executionWindow: MIN_EXECUTION_WINDOW });

        emit DefaultTimelockSet(MIN_DELAY, MIN_EXECUTION_WINDOW);

        _updateRole(PROPOSER_ROLE,  proposer_,  true);
        _updateRole(EXECUTOR_ROLE,  executor_,  true);
        _updateRole(CANCELLER_ROLE, canceller_, true);
        _updateRole(ROLE_ADMIN,     roleAdmin_, true);
    }

    /**************************************************************************************************************************************/
    /*** Token Withdrawer Functions                                                                                                     ***/
    /**************************************************************************************************************************************/

    function acceptTokenWithdrawer() external override {
        address newTokenWithdrawer_ = pendingTokenWithdrawer;

        require(msg.sender == newTokenWithdrawer_, "GT:ATW:NOT_AUTHORIZED");

        tokenWithdrawer        = newTokenWithdrawer_;
        pendingTokenWithdrawer = address(0);

        emit TokenWithdrawerAccepted(newTokenWithdrawer_);
    }

    function setPendingTokenWithdrawer(address newPendingTokenWithdrawer_) external override onlyRole(ROLE_ADMIN) {
        pendingTokenWithdrawer = newPendingTokenWithdrawer_;

        emit PendingTokenWithdrawerSet(newPendingTokenWithdrawer_);
    }

    function withdrawERC20Token(address token_, uint256 amount_) external override {
        require(msg.sender == tokenWithdrawer,                     "GT:WET:NOT_AUTHORIZED");
        require(ERC20Helper.transfer(token_, msg.sender, amount_), "GT:WET:TRANSFER_FAILED");

        emit ERC20TokenWithdrawn(token_, msg.sender, amount_);
    }

    /**************************************************************************************************************************************/
    /*** Timelock Configuration                                                                                                         ***/
    /**************************************************************************************************************************************/

    function setDefaultTimelockParameters(uint32 delay_, uint32 executionWindow_) external override onlySelf {
        require(delay_           >= MIN_DELAY,            "GT:SDTP:INVALID_DELAY");
        require(executionWindow_ >= MIN_EXECUTION_WINDOW, "GT:SDTP:INVALID_EXEC_WINDOW");

        defaultTimelockParameters = TimelockParameters({ delay: delay_, executionWindow: executionWindow_ });

        emit DefaultTimelockSet(delay_, executionWindow_);
    }

    function setFunctionTimelockParameters(
        address target_,
        bytes4  functionSelector_,
        uint32  delay_,
        uint32  executionWindow_
    )
        external override onlySelf
    {
         // Both delay_ & executionWindow_ must be zero to use defaults, or both must meet minimums.
        require(
            (delay_ == 0 && executionWindow_ == 0) ||
            (delay_ >= MIN_DELAY && executionWindow_ >= MIN_EXECUTION_WINDOW),
            "GT:SFTP:INVALID_PARAMETERS"
        );

        functionTimelockParameters[target_][functionSelector_] = TimelockParameters({ delay: delay_, executionWindow: executionWindow_ });

        emit FunctionTimelockSet(target_, functionSelector_, delay_, executionWindow_);
    }

    /**************************************************************************************************************************************/
    /*** Role Management                                                                                                                ***/
    /**************************************************************************************************************************************/

    function updateRole(bytes32 role_, address account_, bool grantRole_) external override onlySelf {
        _updateRole(role_, account_, grantRole_);
    }

    function proposeRoleUpdates(
        bytes32[] calldata roles_,
        address[] calldata accounts_,
        bool[]    calldata shouldGrant_
    )
        external override onlyRole(ROLE_ADMIN)
    {
        require(roles_.length > 0,                    "GT:PRU:EMPTY_ARRAY");
        require(roles_.length == accounts_.length,    "GT:PRU:INVALID_ACCOUNTS_LENGTH");
        require(roles_.length == shouldGrant_.length, "GT:PRU:INVALID_SHOULD_GRANT_LENGTH");

        for (uint256 i = 0; i < roles_.length; i++) {
            _scheduleProposal(address(this), this.updateRole.selector, abi.encode(roles_[i], accounts_[i], shouldGrant_[i]));
        }
    }

    /**************************************************************************************************************************************/
    /*** Proposal Management                                                                                                            ***/
    /**************************************************************************************************************************************/

    function executeProposals(
        uint256[] calldata proposalIds_,
        address[] calldata targets_,
        bytes[]   calldata data_
    )
        external override onlyRole(EXECUTOR_ROLE)
    {
        require(proposalIds_.length != 0,               "GT:EP:EMPTY_ARRAY");
        require(proposalIds_.length == targets_.length, "GT:EP:INVALID_TARGETS_LENGTH");
        require(proposalIds_.length == data_.length,    "GT:EP:INVALID_DATA_LENGTH");

        for (uint256 i = 0; i < proposalIds_.length; i++) {
            Proposal memory proposal_     = proposals[proposalIds_[i]];
            bytes32 expectedProposalHash_ = keccak256(abi.encode(targets_[i], data_[i]));

            require(proposals[proposalIds_[i]].proposalHash != bytes32(0), "GT:EP:PROPOSAL_NOT_FOUND");
            require(isExecutable(proposalIds_[i]),                         "GT:EP:NOT_EXECUTABLE");
            require(expectedProposalHash_ == proposal_.proposalHash,       "GT:EP:INVALID_DATA");

            delete proposals[proposalIds_[i]];

            _call(targets_[i], data_[i]);

            emit ProposalExecuted(proposalIds_[i]);
        }
    }

    function scheduleProposals(address[] calldata targets_, bytes[] calldata data_) external override onlyRole(PROPOSER_ROLE) {
        require(targets_.length != 0,            "GT:SP:EMPTY_ARRAY");
        require(targets_.length == data_.length, "GT:SP:ARRAY_LENGTH_MISMATCH");

        for (uint256 i = 0; i < targets_.length; i++) {
            bytes4 selector_     = bytes4(data_[i][:4]);
            bytes memory params_ = data_[i][4:];

            require(!_isUpdatingRoles(targets_[i], selector_), "GT:SP:UPDATE_ROLE_NOT_ALLOWED");

            _scheduleProposal(targets_[i], selector_, params_);
        }
    }

    function unscheduleProposals(uint256[] calldata proposalIds_) external override onlyRole(CANCELLER_ROLE) {
        for (uint256 i = 0; i < proposalIds_.length; i++) {
            require(proposals[proposalIds_[i]].proposalHash != 0, "GT:UP:PROPOSAL_NOT_FOUND");
            require(proposals[proposalIds_[i]].isUnschedulable,   "GT:UP:NOT_UNSCHEDULABLE");

            delete proposals[proposalIds_[i]];

            emit ProposalUnscheduled(proposalIds_[i]);
        }
    }

    /**************************************************************************************************************************************/
    /*** View Functions                                                                                                                 ***/
    /**************************************************************************************************************************************/

    function isExecutable(uint256 proposalId_) public override view returns (bool isExecutable_) {
        isExecutable_ = block.timestamp >= proposals[proposalId_].delayedUntil && block.timestamp <= proposals[proposalId_].validUntil;
    }

    /**************************************************************************************************************************************/
    /*** Internal Functions                                                                                                             ***/
    /**************************************************************************************************************************************/

    function _call(address target_, bytes calldata calldata_) internal {
        ( bool success_, bytes memory returndata_ ) = target_.call(calldata_);

        if (success_) {
            return;
        }

        if (returndata_.length > 0) {
            assembly ("memory-safe") {
                let size_ := mload(returndata_)
                revert(add(32, returndata_), size_)
            }
        } else {
            revert("GT:EP:CALL_FAILED");
        }
    }

    function _getTimelockParameters(
        address target_, bytes4 selector_, bytes memory parameters_
    )
        internal view returns (TimelockParameters memory timelockParameters_)
    {
        // Use prior timelock params if set when updating timelock params.
        if (target_ == address(this) && selector_ == this.setFunctionTimelockParameters.selector) {
            ( target_, selector_, , ) = abi.decode(parameters_, (address, bytes4, uint32, uint32));
        }

        uint32 functionDelay_ = functionTimelockParameters[target_][selector_].delay;

        timelockParameters_ =
            functionDelay_ == 0 ? defaultTimelockParameters : functionTimelockParameters[target_][selector_];
    }

    function _isUpdatingRoles(address target_, bytes4 selector_) internal view returns (bool isUpdatingRoles_) {
        isUpdatingRoles_ = target_ == address(this) && selector_ == this.updateRole.selector;
    }

    function _updateRole(bytes32 role_, address account_, bool grantRole_) internal {
        require(hasRole[account_][role_] != grantRole_, "GT:UR:ROLE_NOT_CHANGED");

        hasRole[account_][role_] = grantRole_;

        emit RoleUpdated(role_, account_, grantRole_);
    }

    function _scheduleProposal(address target_, bytes4 selector_, bytes memory parameters_) internal {
        require(target_.code.length > 0, "GT:SP:EMPTY_ADDRESS");

        TimelockParameters memory timelockParameters_ = _getTimelockParameters(target_, selector_, parameters_);

        Proposal memory proposal_ = Proposal({
            proposalHash:    keccak256(abi.encode(target_, bytes.concat(selector_, parameters_))),
            scheduledAt:     uint32(block.timestamp),
            delayedUntil:    uint32(block.timestamp) + timelockParameters_.delay,
            validUntil:      uint32(block.timestamp) + timelockParameters_.delay + timelockParameters_.executionWindow,
            isUnschedulable: !_isUpdatingRoles(target_, selector_)
        });

        uint256 latestProposalId_ = ++latestProposalId;

        proposals[latestProposalId_] = proposal_;

        emit ProposalScheduled(latestProposalId_, proposal_);
    }

}
