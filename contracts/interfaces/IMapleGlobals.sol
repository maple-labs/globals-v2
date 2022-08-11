// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.7;

interface IMapleGlobals {

    /**************/
    /*** Events ***/
    /**************/

    event CallScheduled(address indexed caller_, address indexed contract_, bytes32 indexed functionId_, bytes32 dataHash_, uint256 timestamp_);

    event CallUnscheduled(address indexed caller_, address indexed contract_, bytes32 indexed functionId_, bytes32 dataHash_, uint256 timestamp_);

    event DefaultTimelockParametersSet(uint256 previousDelay_, uint256 currentDelay_, uint256 previousDuration_, uint256 currentDuration_);

    event GovernorshipAccepted(address indexed previousGovernor_, address indexed currentGovernor_);

    event MapleTreasurySet(address indexed previousMapleTreasury_, address indexed currentMapleTreasury_);

    event MaxCoverLiquidationPercentSet(address indexed poolManager_, uint256 maxCoverLiquidationPercent_);

    event MinCoverAmountSet(address indexed poolManager_, uint256 minCoverAmount_);

    event PendingGovernorSet(address indexed pendingGovernor_);

    event PlatformManagementFeeRateSet(address indexed poolManager_, uint256 platformManagementFeeRate_);

    event PlatformOriginationFeeRateSet(address indexed poolManager_, uint256 platformOriginationFeeRate_);

    event PlatformServiceFeeRateSet(address indexed poolManager_, uint256 platformServiceFeeRate_);

    event PoolManagerActivated(address indexed poolManager_, address indexed poolDelegate_);

    event PoolManagerOwnershipTransferred(address indexed fromPoolDelegate_, address indexed toPoolDelegate_, address indexed poolManager_);

    event ProtocolPauseSet(address indexed securityAdmin_, bool indexed protocolPaused_);

    event SecurityAdminSet(address indexed previousSecurityAdmin_, address indexed currentSecurityAdmin_);

    event TimelockWindowSet(address indexed contract_, bytes32 indexed functionId_, uint128 delay_, uint128 duration_);

    event ValidBorrowerSet(address indexed borrower_, bool indexed isValid_);

    event ValidFactorySet(bytes32 indexed factoryKey_, address indexed factory_, bool indexed isValid_);

    event ValidPoolAssetSet(address indexed poolAsset_, bool indexed isValid_);

    event ValidPoolDelegateSet(address indexed account_, bool indexed isValid_);

    event ValidPoolDeployerSet(address indexed poolDeployer_, bool indexed isValid_);

    /***********************/
    /*** State Variables ***/
    /***********************/

    function defaultTimelockParameters() external view returns (uint128 defaultTimelockDelay_, uint128 defaultTimelockDuration_);

    function isBorrower(address borrower_) external view returns (bool isValid_);

    function isFactory(bytes32 factoryId_, address factory_) external view returns (bool isValid_);

    function isPoolAsset(address poolAsset_) external view returns (bool isValid_);

    function isPoolDelegate(address account_) external view returns (bool isValid_);

    function isPoolDeployer(address account_) external view returns (bool isValid_);

    function getLatestPrice(address asset_) external view returns (uint256 price_);

    function governor() external view returns (address governor_);

    function manualOverridePrice(address asset_) external view returns (uint256 manualOverridePrice_);

    function mapleTreasury() external view returns (address governor_);

    function maxCoverLiquidationPercent(address poolManager_) external view returns (uint256 maxCoverLiquidationPercent_);

    function minCoverAmount(address poolManager_) external view returns (uint256 minCoverAmount_);

    function oracleFor(address asset_) external view returns (address oracle_);

    function ownedPoolManager(address account_) external view returns (address poolManager_);

    function pendingGovernor() external view returns (address pendingGovernor_);

    function platformManagementFeeRate(address poolManager_) external view returns (uint256 platformManagementFeeRate_);

    function platformOriginationFeeRate(address poolManager_) external view returns (uint256 platformOriginationFeeRate_);

    function platformServiceFeeRate(address poolManager_) external view returns (uint256 platformServiceFeeRate_);

    function poolDelegates(address poolDelegate_) external view returns (address ownedPoolManager_, bool isPoolDelegate_);

    function protocolPaused() external view returns (bool protocolPaused_);

    function scheduledCalls(address caller_, address contract_, bytes32 functionId_) external view returns (uint256 timestamp_, bytes32 callHash_);

    function securityAdmin() external view returns (address securityAdmin_);

    function timelockParametersOf(address contract_, bytes32 functionId_) external view returns (uint128 delay_, uint128 duration_);

    /**********************/
    /*** Global Setters ***/
    /**********************/

    function activatePoolManager(address poolManager_) external;

    function setMapleTreasury(address mapleTreasury_) external;

    function setPriceOracle(address asset_, address priceOracle_) external;

    function setSecurityAdmin(address securityAdmin_) external;

    function setDefaultTimelockParameters(uint128 defaultTimelockDelay_, uint128 defaultTimelockDuration_) external;

    /***********************/
    /*** Boolean Setters ***/
    /***********************/

    function setProtocolPause(bool protocolPaused_) external;

    /*************************/
    /*** Allowlist Setters ***/
    /*************************/

    function setValidBorrower(address borrower_, bool isValid_) external;

    function setValidFactory(bytes32 factoryKey_, address factory_, bool isValid_) external;

    function setValidPoolAsset(address poolAsset_, bool isValid_) external;

    function setValidPoolDelegate(address poolDelegate_, bool isValid_) external;

    function setValidPoolDeployer(address poolDeployer_, bool isValid_) external;

    /*********************/
    /*** Price Setters ***/
    /*********************/

    function setManualOverridePrice(address asset_, uint256 price_) external;

    /*********************/
    /*** Cover Setters ***/
    /*********************/

    function setMaxCoverLiquidationPercent(address poolManager_, uint256 maxCoverLiquidationPercent_) external;

    function setMinCoverAmount(address poolManager_, uint256 minCoverAmount_) external;

    /*******************/
    /*** Fee Setters ***/
    /*******************/

    function setPlatformManagementFeeRate(address poolManager_, uint256 platformManagementFeeRate_) external;

    function setPlatformOriginationFeeRate(address poolManager_, uint256 platformOriginationFeeRate_) external;

    function setPlatformServiceFeeRate(address poolManager_, uint256 platformServiceFeeRate_) external;

    /*********************************/
    /*** Contact Control Functions ***/
    /*********************************/

    function setTimelockWindow(address contact_, bytes32 functionId_, uint128 delay_, uint128 duration_) external;

    function setTimelockWindows(address contact_, bytes32[] calldata functionIds_, uint128[] calldata delays_, uint128[] calldata durations_) external;

    function transferOwnedPoolManager(address fromPoolDelegate_, address toPoolDelegate_) external;

    /**************************/
    /*** Schedule Functions ***/
    /**************************/

    function scheduleCall(address contract_, bytes32 functionId_, bytes calldata callData_) external;

    function unscheduleCall(address caller_, bytes32 functionId_, bytes calldata callData_) external;

    function unscheduleCall(address caller_, address contract_, bytes32 functionId_, bytes calldata callData_) external;

    function isValidScheduledCall(address caller_, address contract_, bytes32 functionId_, bytes calldata callData_) external view returns (bool isValid_);

}
