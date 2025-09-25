// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.7;

interface IGovernorTimelock {

    /**************************************************************************************************************************************/
    /*** Structs                                                                                                                        ***/
    /**************************************************************************************************************************************/

    struct Proposal {
        bytes32 proposalHash;
        bool    isUnschedulable;
        uint32  scheduledAt;
        uint32  delayedUntil;
        uint32  validUntil;
    }

    struct TimelockParameters {
        uint32 delay;
        uint32 executionWindow;
    }

    /**************************************************************************************************************************************/
    /*** Events                                                                                                                         ***/
    /**************************************************************************************************************************************/

    /**
     * @notice Emitted when the default timelock parameters are set
     * @param  delay           The new default delay
     * @param  executionWindow The new default execution window
     */
    event DefaultTimelockSet(uint32 delay, uint32 executionWindow);

    /**
     * @notice Emitted when tokens are withdrawn from the governor timelock contract
     * @param  token    The address of the token withdrawn
     * @param  receiver The address of the receiver of the tokens
     * @param  amount   The amount of tokens withdrawn
     */
    event ERC20TokenWithdrawn(address indexed token, address indexed receiver, uint256 amount);

    /**
     * @notice Emitted when the function timelock parameters are set
     * @param  target           The target of the function
     * @param  functionSelector The function selector
     * @param  delay            The new delay
     * @param  executionWindow  The new execution window
     */
    event FunctionTimelockSet(address indexed target, bytes4  indexed functionSelector, uint32 delay, uint32 executionWindow);

    /**
     * @notice Emitted when the pending token withdrawer is set
     * @param  newPendingTokenWithdrawer The address of the new pending token withdrawer
     */
    event PendingTokenWithdrawerSet(address indexed newPendingTokenWithdrawer);

    /**
     * @notice Emitted when a proposal is executed
     * @param  proposalId The id of the proposal
     */
    event ProposalExecuted(uint256 indexed proposalId);

    /**
     * @notice Emitted when a proposal is scheduled
     * @param  proposalId The id of the proposal
     * @param  proposal   The proposal
     */
    event ProposalScheduled(uint256 indexed proposalId, Proposal proposal);

    /**
     * @notice Emitted when a proposal is unscheduled
     * @param  proposalId The id of the proposal
     */
    event ProposalUnscheduled(uint256 indexed proposalId);

    /**
     * @notice Emitted when a role is updated
     * @param  role      The role updated
     * @param  account   The account updated the role for
     * @param  grantRole Whether the role is granted or revoked
     */
    event RoleUpdated(bytes32 indexed role, address indexed account, bool grantRole);

    /**
     * @notice Emitted when the token withdrawer is accepted
     * @param  tokenWithdrawer The address of the new token withdrawer
     */
    event TokenWithdrawerAccepted(address indexed tokenWithdrawer);

    /**************************************************************************************************************************************/
    /*** Role constants                                                                                                                 ***/
    /**************************************************************************************************************************************/

    /**
     * @notice Returns the bytes32 representation of the canceler role
     * @dev    Address that has the canceler role can unschedule proposals but can not unschedule role updates
     * @return cancelerRole The canceler role
     */
    function CANCELLER_ROLE() external view returns (bytes32 cancelerRole);

    /**
     * @notice Returns the bytes32 representation of the executor role
     * @dev    Address that has the executor role can execute all proposals including role updates
     * @return executorRole The executor role
     */
    function EXECUTOR_ROLE() external view returns (bytes32 executorRole);

    /**
     * @notice Returns the bytes32 representation of the proposer role
     * @dev    Address that has the proposer role can schedule proposals but can not schedule role updates
     * @return proposerRole The proposer role
     */
    function PROPOSER_ROLE() external view returns (bytes32 proposerRole);

    /**
     * @notice Returns the bytes32 representation of the role admin role
     * @dev    Address that has the role admin role can update roles including the role admin role itself
     * @return roleAdmin The role admin role
     */
    function ROLE_ADMIN() external view returns (bytes32 roleAdmin);

    /**************************************************************************************************************************************/
    /*** Timelock constants                                                                                                             ***/
    /**************************************************************************************************************************************/

    /**
     * @notice Returns the minimum delay for a proposal
     * @return minDelay The minimum delay for a proposal
     */
    function MIN_DELAY() external view returns (uint32 minDelay);

    /**
     * @notice Returns the minimum execution window for a proposal
     * @return minExecutionWindow The minimum execution window for a proposal
     */
    function MIN_EXECUTION_WINDOW() external view returns (uint32 minExecutionWindow);

    /**************************************************************************************************************************************/
    /*** View Functions                                                                                                                 ***/
    /**************************************************************************************************************************************/

    /**
     * @notice Returns the default timelock parameters
     * @return delay           The delay
     * @return executionWindow The execution window
     */
    function defaultTimelockParameters() external view returns (uint32 delay, uint32 executionWindow);

    /**
     * @notice Returns the timelock parameters for a given target and function selector
     * @param  target           The target of the function
     * @param  functionSelector The function selector
     * @return delay            The delay
     * @return executionWindow  The execution window
     */
    function functionTimelockParameters(
        address target,
        bytes4 functionSelector
    ) external view returns (uint32 delay, uint32 executionWindow);

    /**
     * @notice Checks if an account has a role
     * @param  account      The account to check
     * @param  role         The role to check
     * @return doesHaveRole Whether the account has the role
     */
    function hasRole(address account, bytes32 role) external view returns (bool doesHaveRole);

    /**
     * @notice Checks if a proposal is executable
     * @param  proposalId   The id of the proposal
     * @return isExecutable Whether the proposal is executable
     */
    function isExecutable(uint256 proposalId) external view returns (bool isExecutable);

    /**
     * @notice Returns the latest proposal id
     * @return latestProposalId The latest proposal id
     */
    function latestProposalId() external view returns (uint256 latestProposalId);

    /**
     * @notice Returns the pending token withdrawer
     * @return pendingTokenWithdrawer The address of the pending token withdrawer
     */
    function pendingTokenWithdrawer() external view returns (address pendingTokenWithdrawer);

    /**
     * @notice Returns the proposal for a given proposal id
     * @param  proposalId The id of the proposal
     * @return proposalHash    The hash of the proposal
     * @return isUnschedulable Whether the proposal is unschedulable
     * @return scheduledAt     The timestamp when the proposal was scheduled
     * @return delayedUntil    The timestamp when the proposal was delayed
     * @return validUntil      The timestamp when the proposal was valid
     */
    function proposals(uint256 proposalId) external view returns (
        bytes32 proposalHash,
        bool    isUnschedulable,
        uint32  scheduledAt,
        uint32  delayedUntil,
        uint32  validUntil
    );

    /**
     * @notice Returns the token withdrawer
     * @return tokenWithdrawer The address of the token withdrawer
     */
    function tokenWithdrawer() external view returns (address tokenWithdrawer);

    /**************************************************************************************************************************************/
    /*** Token Withdrawer Functions                                                                                                     ***/
    /**************************************************************************************************************************************/

    /**
     * @notice Accepts the token withdrawer role and sets pending token withdrawer to zero address
     * @dev    Only the pending token withdrawer can accept the token withdrawer role
     */
    function acceptTokenWithdrawer() external;

    /**
     * @notice Sets the pending token withdrawer
     * @dev    Only the token withdrawer can set the pending token withdrawer
     * @param  newPendingTokenWithdrawer The address of the new pending token withdrawer
     */
    function setPendingTokenWithdrawer(address newPendingTokenWithdrawer) external;

    /**
     * @notice Withdraws tokens from the governor timelock contract
     * @dev    Only the token withdrawer can withdraw tokens and tokens are sent to the token withdrawer
     * @param  token  The address of the token to withdraw
     * @param  amount The amount of tokens to withdraw
     */
    function withdrawERC20Token(address token, uint256 amount) external;

    /**************************************************************************************************************************************/
    /*** Timelock Configuration                                                                                                         ***/
    /**************************************************************************************************************************************/

    /**
     * @notice Sets the default timelock parameters
     * @param  delay           The new default delay
     * @param  executionWindow The new default execution window
     */
    function setDefaultTimelockParameters(uint32 delay, uint32 executionWindow) external;

    /**
     * @notice Sets the function timelock parameters
     * @param  target           The target of the function
     * @param  functionSelector The function selector
     * @param  delay            The new delay
     * @param  executionWindow  The new execution window
     */
    function setFunctionTimelockParameters(address target, bytes4 functionSelector, uint32 delay, uint32 executionWindow) external;

    /**************************************************************************************************************************************/
    /*** Role Management                                                                                                                ***/
    /**************************************************************************************************************************************/

    /**
     * @notice Updates a role
     * @dev    The role updating needs to be done through the timelock contract
     * @param  role      The role to update
     * @param  account   The account to update the role for
     * @param  grantRole Whether the role is granted or revoked
     */
    function updateRole(bytes32 role, address account, bool grantRole) external;

    /**************************************************************************************************************************************/
    /*** Proposal Management                                                                                                            ***/
    /**************************************************************************************************************************************/

    /**
     * @notice Executes proposals
     * @dev    The proposalIds, targets and data arrays must have the same length
     * @param  proposalIds The ids of the proposals to execute
     * @param  targets     The targets of the proposals
     * @param  data        The calldata of the proposals that the contract is going to execute
     */
    function executeProposals(
        uint256[] calldata proposalIds,
        address[] calldata targets,
        bytes[]   calldata data
    ) external;

    /**
     * @notice Proposes to update roles
     * @dev    The role updating needs to be done through the timelock contract
     * @param  roles       The roles to update
     * @param  accounts    The accounts to update the roles for
     * @param  shouldGrant Whether to grant or revoke the roles
     */
    function proposeRoleUpdates(bytes32[] calldata roles, address[] calldata accounts, bool[] calldata shouldGrant) external;

    /**
     * @notice Schedules proposals
     * @dev    The targets and data arrays must have the same length
     * @param  targets The targets of the proposals
     * @param  data    The calldata of the proposals that the contract is going to execute
     */
    function scheduleProposals(address[] calldata targets, bytes[] calldata data) external;

    /**
     * @notice Unschedule proposals
     * @dev    The proposalIds array must not contain duplicates
     * @param  proposalIds The ids of the proposals to unschedule
     */
    function unscheduleProposals(uint256[] calldata proposalIds) external;

}
