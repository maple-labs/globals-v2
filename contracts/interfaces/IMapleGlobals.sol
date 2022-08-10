// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.7;

interface IMapleGlobals {

    /***********************/
    /*** State Variables ***/
    /***********************/

    function callSchedule(bytes32 functionId_, address caller_) external view returns (uint256 callSchedule_);

    function isBorrower(address borrower_) external view returns (bool isValid_);

    function isFactory(bytes32 factoryId_, address factory_) external view returns (bool isValid_);

    function isPoolAsset(address poolAsset_) external view returns (bool isValid_);

    function isPoolDelegate(address account_) external view returns (bool isValid_);

    function isPoolDeployer(address account_) external view returns (bool isValid_);

    function getLatestPrice(address asset_) external view returns (uint256 price_);

    function governor() external view returns (address governor_);

    function manualOverridePrice(address asset_) external view returns (uint256 manualOverridePrice_);

    function mapleTreasury() external view returns (address governor_);

    function maxValue(address pool_, bytes32 paramId_) external view returns (uint256 maxValue_);

    function maxCoverLiquidationPercent(address pool_) external view returns (uint256 maxCoverLiquidationPercent_);

    function minCoverAmount(address pool_) external view returns (uint256 minCoverAmount_);

    function minTimelock(bytes32 functionId_) external view returns (uint256 minTimelock);

    function minValue(address pool_, bytes32 paramId_) external view returns (uint256 minValue_);

    function oracleFor(address asset_) external view returns (address oracle_);

    function ownedPool(address account_) external view returns (address pool_);

    function pendingGovernor() external view returns (address pendingGovernor_);

    function platformManagementFeeRate(address pool_) external view returns (uint256 platformManagementFeeRate_);

    function platformOriginationFeeRate(address pool_) external view returns (uint256 platformOriginationFeeRate_);

    function platformServiceFeeRate(address pool_) external view returns (uint256 platformServiceFeeRate_);

    function protocolPaused() external view returns (bool protocolPaused_);

    function securityAdmin() external view returns (address securityAdmin_);

    /***********************/
    /*** Address Setters ***/
    /***********************/

    function activatePool(address pool_) external;

    function setMapleTreasury(address mapleTreasury_) external;

    function setPriceOracle(address asset_, address priceOracle_) external;

    function setSecurityAdmin(address securityAdmin_) external;

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

    function setMaxCoverLiquidationPercent(address pool_, uint256 maxCoverLiquidationPercent_) external;

    function setMinCoverAmount(address pool_, uint256 minCoverAmount_) external;

    /*******************/
    /*** Fee Setters ***/
    /*******************/

    function setPlatformManagementFeeRate(address pool_, uint256 platformManagementFeeRate_) external;

    function setPlatformOriginationFeeRate(address pool_, uint256 platformOriginationFeeRate_) external;

    function setPlatformServiceFeeRate(address pool_, uint256 platformServiceFeeRate_) external;

    /*********************/
    /*** Range Setters ***/
    /*********************/

    function setRange(address pool_, bytes32 paramId_, uint256 minValue_, uint256 maxValue_) external;

    /************************/
    /*** Timelock Setters ***/
    /************************/

    function setMinTimelock(bytes32 functionId_, uint256 duration_) external;

    /**************************/
    /*** Schedule Functions ***/
    /**************************/

    function scheduleCall(bytes32 functionId_) external;

}
