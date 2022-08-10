// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.7;

import { console } from "../modules/contract-test-utils/contracts/test.sol";

import { NonTransparentProxied } from "../modules/non-transparent-proxy/contracts/NonTransparentProxied.sol";

import { IMapleGlobals } from "./interfaces/IMapleGlobals.sol";

import {
    IChainlinkAggregatorV3Like,
    IPoolLike,
    IPoolManagerLike
} from "./interfaces/Interfaces.sol";

// TODO: Natspec
// TODO: Timelocks?
// TODO: Figure out how to make pool delegate only manage one pool per address
//       `setFinalizedPool` that writes to a mapping in globals storage?
//       That way we can check the mapping during pool instantiation to check if the PD is:
//       1. Allowlisted
//       2. Not already managing a pool
// TODO: Should the governor be able to update minTimelock during the timelock of the call?
//       Or should we save it on schedule?
// NOTE: It will be crucial to check that values that are returned from globals are not zero in case of a bad key being passed in.

contract MapleGlobals is IMapleGlobals, NonTransparentProxied {

    struct PoolDelegate {
        address ownedPoolManager;
        bool    isPoolDelegate;
    }

    /***************/
    /*** Storage ***/
    /***************/

    uint256 public constant HUNDRED_PERCENT = 1e18;

    address public override mapleTreasury;
    address public override pendingGovernor;
    address public override securityAdmin;

    bool public override protocolPaused;

    mapping(address => address) public override oracleFor;

    mapping(address => bool) public override isBorrower;
    mapping(address => bool) public override isPoolAsset;
    mapping(address => bool) public override isPoolDeployer;

    mapping(address => uint256) public override manualOverridePrice;
    mapping(address => uint256) public override maxCoverLiquidationPercent;
    mapping(address => uint256) public override minCoverAmount;
    mapping(address => uint256) public override platformManagementFeeRate;
    mapping(address => uint256) public override platformOriginationFeeRate;
    mapping(address => uint256) public override platformServiceFeeRate;

    mapping(bytes32 => uint256) public override minTimelock;

    mapping(address => mapping(bytes32 => uint256)) public override maxValue;
    mapping(address => mapping(bytes32 => uint256)) public override minValue;

    mapping(bytes32 => mapping(address => bool)) public override isFactory;

    mapping(bytes32 => mapping(address => uint256)) public override callSchedule;

    mapping(address => PoolDelegate) public poolDelegate;

    /*****************/
    /*** Modifiers ***/
    /*****************/

    modifier isGovernor {
        require(msg.sender == admin(), "MG:NOT_GOVERNOR");
        _;
    }

    /***********************************/
    /*** Governor Transfer Functions ***/
    /***********************************/

    function acceptGovernor() external {
        require(msg.sender == pendingGovernor, "MG:NOT_PENDING_GOVERNOR");
        _setAddress(ADMIN_SLOT, msg.sender);
        pendingGovernor = address(0);
    }

    function setPendingGovernor(address pendingGovernor_) external isGovernor {
        pendingGovernor = pendingGovernor_;
    }

    /***********************/
    /*** Address Setters ***/
    /***********************/

    function activatePool(address poolManager_) external override isGovernor {
        address poolDelegate_ = IPoolManagerLike(poolManager_).poolDelegate();

        poolDelegate[poolDelegate_].ownedPoolManager = poolManager_;

        IPoolManagerLike(poolManager_).setActive(true);

        // Note: minCoverAmount is not enforced at activation time.
    }

    function setMapleTreasury(address mapleTreasury_) external override isGovernor {
        mapleTreasury = mapleTreasury_;
    }

    function setPriceOracle(address asset_, address oracle_) external override isGovernor {
        oracleFor[asset_] = oracle_;
    }

    function setSecurityAdmin(address securityAdmin_) external override isGovernor {
        securityAdmin = securityAdmin_;
    }

    /***********************/
    /*** Boolean Setters ***/
    /***********************/

    function setProtocolPause(bool protocolPaused_) external override {
        require(msg.sender == securityAdmin, "MG:SPP:NOT_SECURITY_ADMIN");
        protocolPaused = protocolPaused_;
    }

    /*************************/
    /*** Allowlist Setters ***/
    /*************************/

    function setValidBorrower(address borrower_, bool isValid_) external override isGovernor {
        isBorrower[borrower_] = isValid_;
    }

    function setValidFactory(bytes32 factoryKey_, address factory_, bool isValid_) external override isGovernor {
        isFactory[factoryKey_][factory_] = isValid_;
    }

    function setValidPoolAsset(address poolAsset_, bool isValid_) external override isGovernor {
        isPoolAsset[poolAsset_] = isValid_;
    }

    function setValidPoolDelegate(address account_, bool isValid_) external override isGovernor {
        require(account_ != address(0), "MG:SVPD:ZERO_ADDRESS");

        // Can only remove pool delegates once they no longer own a pool.
        if (!isValid_) {
            require(poolDelegate[account_].ownedPoolManager == address(0), "MG:SVPD:OWNS_POOL");
        }

        poolDelegate[account_].isPoolDelegate = isValid_;
    }

    function setValidPoolDeployer(address poolDeployer_, bool isValid_) external override isGovernor {
        isPoolDeployer[poolDeployer_] = isValid_;
    }

    /*********************/
    /*** Price Setters ***/
    /*********************/

    function setManualOverridePrice(address asset_, uint256 price_) external override isGovernor {
        manualOverridePrice[asset_] = price_;
    }

    /*********************/
    /*** Cover Setters ***/
    /*********************/

    function setMinCoverAmount(address poolManager_, uint256 minCoverAmount_) external override isGovernor {
        minCoverAmount[poolManager_] = minCoverAmount_;
    }

    function setMaxCoverLiquidationPercent(address poolManager_, uint256 maxCoverLiquidationPercent_) external override isGovernor {
        require(maxCoverLiquidationPercent_ <= HUNDRED_PERCENT, "MG:SMCLP:GT_100");

        maxCoverLiquidationPercent[poolManager_] = maxCoverLiquidationPercent_;
    }

    /*******************/
    /*** Fee Setters ***/
    /*******************/

    function setPlatformManagementFeeRate(address poolManager_, uint256 platformManagementFeeRate_) external override isGovernor {
        require(platformManagementFeeRate_ <= HUNDRED_PERCENT, "MG:SPMFR:RATE_GT_100");
        platformManagementFeeRate[poolManager_] = platformManagementFeeRate_;
    }

    function setPlatformOriginationFeeRate(address poolManager_, uint256 platformOriginationFeeRate_) external override isGovernor {
        require(platformOriginationFeeRate_ <= HUNDRED_PERCENT, "MG:SPOFR:RATE_GT_100");
        platformOriginationFeeRate[poolManager_] = platformOriginationFeeRate_;
    }

    function setPlatformServiceFeeRate(address poolManager_, uint256 platformServiceFeeRate_) external override isGovernor {
        require(platformServiceFeeRate_ <= HUNDRED_PERCENT, "MG:SPSFR:RATE_GT_100");
        platformServiceFeeRate[poolManager_] = platformServiceFeeRate_;
    }

    /*********************/
    /*** Range Setters ***/
    /*********************/

    function setRange(address poolManager_, bytes32 paramId_, uint256 minValue_, uint256 maxValue_) external override isGovernor {
        minValue[poolManager_][paramId_] = minValue_;
        maxValue[poolManager_][paramId_] = maxValue_;
    }

    /************************/
    /*** Timelock Setters ***/
    /************************/

    function setMinTimelock(bytes32 functionId_, uint256 duration_) external override isGovernor {
        minTimelock[functionId_] = duration_;
    }

    /**************************/
    /*** Schedule Functions ***/
    /**************************/

    function scheduleCall(bytes32 functionId_) external override {
        callSchedule[functionId_][msg.sender] = block.timestamp + minTimelock[functionId_];
    }

    /**********************/
    /*** View Functions ***/
    /**********************/

    function getLatestPrice(address asset_) external override view returns (uint256) {
        // If governor has overriden price because of oracle outage, return overriden price.
        if (manualOverridePrice[asset_] != 0) return manualOverridePrice[asset_];

        ( uint80 roundId_, int256 price_, , uint256 updatedAt_, uint80 answeredInRound_ ) = IChainlinkAggregatorV3Like(oracleFor[asset_]).latestRoundData();

        require(updatedAt_ != 0,              "MG:GLP:ROUND_NOT_COMPLETE");
        require(answeredInRound_ >= roundId_, "MG:GLP:STALE_DATA");
        require(price_ != int256(0),          "MG:GLP:ZERO_PRICE");

        return uint256(price_);
    }

    // TODO: Add setter for updating the governor address.
    function governor() external view override returns (address governor_) {
        governor_ = admin();
    }

    function isPoolDelegate(address account_) external view override returns (bool isPoolDelegate_) {
        isPoolDelegate_ = poolDelegate[account_].isPoolDelegate;
    }

    function ownedPoolManager(address account_) external view override returns (address poolManager_) {
        poolManager_ = poolDelegate[account_].ownedPoolManager;
    }

    /************************/
    /*** Helper Functions ***/
    /************************/

    function _pastTimelock(bytes32 functionId_, address caller_) internal view returns (bool pastTimelock_) {
        return block.timestamp >= callSchedule[functionId_][caller_];
    }

    function _setAddress(bytes32 slot_, address value_) private {
        assembly {
            sstore(slot_, value_)
        }
    }

}
