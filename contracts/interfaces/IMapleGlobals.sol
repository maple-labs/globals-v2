// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.7;

interface IMapleGlobals {

    /***********************/
    /*** State Variables ***/
    /***********************/

    function adminFeeSplit(address pool_) external view returns (uint256 adminFeeSplit_);

    function callSchedule(bytes32 functionId_, address caller_) external view returns (uint256 callSchedule_);

    function isBorrower(address borrower_) external view returns (bool isValid_);

    function isFactory(bytes32 factoryId_, address factory_) external view returns (bool isValid_);

    function isPoolAsset(address poolAsset_) external view returns (bool isValid_);

    function isPoolDelegate(address account_) external view returns (bool isValid_);

    function governor() external view returns (address governor_);

    function managementFeeSplit(address pool_) external view returns (uint256 managementFeeSplit_);

    function mapleTreasury() external view returns (address governor_);

    function maxValue(address pool_, bytes32 paramId_) external view returns (uint256 maxValue_);

    function minTimelock(bytes32 functionId_) external view returns (uint256 minTimelock);

    function minValue(address pool_, bytes32 paramId_) external view returns (uint256 minValue_);

    function originationFeeSplit(address pool_) external view returns (uint256 originationFeeSplit_);

    function ownedPool(address account_) external view returns (address pool_);

    function platformFee(address pool_) external view returns (uint256 platformFee_);

    function protocolPaused() external view returns (bool protocolPaused_);

    function securityAdmin() external view returns (address securityAdmin_);

    /***********************/
    /*** Address Setters ***/
    /***********************/

    function activatePool(address pool_) external;

    function setMapleTreasury(address mapleTreasury_) external;
    
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

    /*******************/
    /*** Fee Setters ***/
    /*******************/

    function setAdminFeeSplit(address pool_, uint256 adminFeeSplit_) external;

    function setManagementFeeSplit(address pool_, uint256 managementFeeSplit_) external;

    function setOriginationFeeSplit(address pool_, uint256 originationFeeSplit_) external;

    function setPlatformFee(address pool_, uint256 platformFee_) external;

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
