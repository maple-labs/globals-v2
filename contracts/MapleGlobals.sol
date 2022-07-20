// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.7;

import { NonTransparentProxied } from "../modules/non-transparent-proxy/contracts/NonTransparentProxied.sol";

import { IMapleGlobals }               from "./interfaces/IMapleGlobals.sol";
import { IPoolLike, IPoolManagerLike } from "./interfaces/Interfaces.sol";

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
        address ownedPool;
        bool    isPoolDelegate;
    }

    /***************/
    /*** Storage ***/
    /***************/

    address public override mapleTreasury;
    address public override pendingGovernor;
    address public override securityAdmin;

    bool public override protocolPaused;

    mapping(address => bool) public override isBorrower;
    mapping(address => bool) public override isPoolAsset;

    mapping(address => uint256) public override adminFeeSplit;
    mapping(address => uint256) public override managementFeeSplit;
    mapping(address => uint256) public override maxCoverLiquidationPercent;
    mapping(address => uint256) public override minCoverAmount;
    mapping(address => uint256) public override originationFeeSplit;
    mapping(address => uint256) public override platformFee;

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

    /**********************/
    /*** View Functions ***/
    /**********************/

    // TODO: Add setter for updating the governor address.
    function governor() external view override returns (address governor_) {
        governor_ = admin();
    }

    function isPoolDelegate(address account_) external view override returns (bool isPoolDelegate_) {
        isPoolDelegate_ = poolDelegate[account_].isPoolDelegate;
    }

    function ownedPool(address account_) external view override returns (address pool_) {
        pool_ = poolDelegate[account_].ownedPool;
    }

    /***********************/
    /*** Address Setters ***/
    /***********************/

    function activatePool(address pool_) external override isGovernor {
        address manager_ = IPoolLike(pool_).manager();
        address admin_   = IPoolManagerLike(manager_).admin();

        poolDelegate[admin_].ownedPool = pool_;

        IPoolManagerLike(manager_).setActive(true);

        // Note: minCoverAmount is not enforced at activation time.
    }

    function setMapleTreasury(address mapleTreasury_) external override isGovernor {
        mapleTreasury = mapleTreasury_;
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
            require(poolDelegate[account_].ownedPool == address(0), "MG:SVPD:OWNS_POOL");
        }

        poolDelegate[account_].isPoolDelegate = isValid_;
    }

    /*********************/
    /*** Cover Setters ***/
    /*********************/

    function setMinCoverAmount(address pool_, uint256 minCoverAmount_) external override isGovernor {
        minCoverAmount[pool_] = minCoverAmount_;
    }

    function setMaxCoverLiquidationPercent(address pool_, uint256 maxCoverLiquidationPercent_) external override isGovernor {
        require(maxCoverLiquidationPercent_ <= 100_00, "MG:SMCLP:GT_100");

        maxCoverLiquidationPercent[pool_] = maxCoverLiquidationPercent_;
    }

    /*******************/
    /*** Fee Setters ***/
    /*******************/

    function setAdminFeeSplit(address pool_, uint256 adminFeeSplit_) external override isGovernor {
        require(adminFeeSplit_ <= 100_00, "MG:SAFS:SPLIT_GT_100");
        adminFeeSplit[pool_] = adminFeeSplit_;
    }

    function setManagementFeeSplit(address pool_, uint256 managementFeeSplit_) external override isGovernor {
        require(managementFeeSplit_ <= 100_00, "MG:SMFS:SPLIT_GT_100");
        managementFeeSplit[pool_] = managementFeeSplit_;
    }

    function setOriginationFeeSplit(address pool_, uint256 originationFeeSplit_) external override isGovernor {
        require(originationFeeSplit_ <= 100_00, "MG:SOFS:SPLIT_GT_100");
        originationFeeSplit[pool_] = originationFeeSplit_;
    }

    function setPlatformFee(address pool_, uint256 platformFee_) external override isGovernor {
        require(platformFee_ <= 100_00, "MG:SPF:FEE_GT_100");
        platformFee[pool_] = platformFee_;
    }

    /*********************/
    /*** Range Setters ***/
    /*********************/

    function setRange(address pool_, bytes32 paramId_, uint256 minValue_, uint256 maxValue_) external override isGovernor {
        minValue[pool_][paramId_] = minValue_;
        maxValue[pool_][paramId_] = maxValue_;
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
