// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.7;

import { Address, TestUtils }  from "../modules/contract-test-utils/contracts/test.sol";
import { NonTransparentProxy } from "../modules/non-transparent-proxy/contracts/NonTransparentProxy.sol";

import { MapleGlobals } from "../contracts/MapleGlobals.sol";

import { MockChainlinkOracle, MockPoolManager } from "./mocks/Mocks.sol";

contract BaseMapleGlobalsTest is TestUtils {

    address GOVERNOR    = address(new Address());
    address SET_ADDRESS = address(new Address());

    address implementation;

    MapleGlobals globals;

    function setUp() public virtual {
        implementation = address(new MapleGlobals());
        globals        = MapleGlobals(address(new NonTransparentProxy(GOVERNOR, address(implementation))));
    }

}

/***********************/
/*** Address Setters ***/
/***********************/

contract AcceptGovernorTests is BaseMapleGlobalsTest {

    bytes32 constant ADMIN_SLOT = bytes32(uint256(keccak256("eip1967.proxy.admin")) - 1);

    function test_acceptGovernor_notPendingGovernor() external {
        vm.expectRevert("MG:NOT_PENDING_GOVERNOR");
        globals.acceptGovernor();
    }

    function test_acceptGovernor() external {
        vm.prank(GOVERNOR);
        globals.setPendingGovernor(SET_ADDRESS);

        address ADMIN = address(uint160(uint256(vm.load(address(globals), ADMIN_SLOT))));

        assertEq(ADMIN,                     GOVERNOR);
        assertEq(globals.admin(),           GOVERNOR);
        assertEq(globals.governor(),        GOVERNOR);
        assertEq(globals.pendingGovernor(), SET_ADDRESS);

        vm.prank(SET_ADDRESS);
        globals.acceptGovernor();

        ADMIN = address(uint160(uint256(vm.load(address(globals), ADMIN_SLOT))));

        assertEq(ADMIN,                     SET_ADDRESS);
        assertEq(globals.admin(),           SET_ADDRESS);
        assertEq(globals.governor(),        SET_ADDRESS);
        assertEq(globals.pendingGovernor(), address(0));
    }

}

contract SetMapleTreasuryTests is BaseMapleGlobalsTest {

    function test_setMapleTreasury_notGovernor() external {
        vm.expectRevert("MG:NOT_GOVERNOR");
        globals.setMapleTreasury(SET_ADDRESS);
    }

    function test_setMapleTreasury() external {
        assertEq(globals.mapleTreasury(), address(0));

        vm.prank(GOVERNOR);
        globals.setMapleTreasury(SET_ADDRESS);

        assertEq(globals.mapleTreasury(), SET_ADDRESS);
    }

}

contract SetPriceOracleTests is BaseMapleGlobalsTest {

    address ASSET = address(new Address());

    function test_setPriceOracle_notGovernor() external {
        vm.expectRevert("MG:NOT_GOVERNOR");
        globals.setPriceOracle(ASSET, SET_ADDRESS);
    }

    function test_setPriceOracle() external {
        assertEq(globals.oracleFor(ASSET), address(0));

        vm.prank(GOVERNOR);
        globals.setPriceOracle(ASSET, SET_ADDRESS);

        assertEq(globals.oracleFor(ASSET), SET_ADDRESS);
    }

}

contract SetPendingGovernorTests is BaseMapleGlobalsTest {

    function test_setPendingGovernor_notGovernor() external {
        vm.expectRevert("MG:NOT_GOVERNOR");
        globals.setPendingGovernor(SET_ADDRESS);
    }

    function test_setPendingGovernor() external {
        assertEq(globals.pendingGovernor(), address(0));

        vm.prank(GOVERNOR);
        globals.setPendingGovernor(SET_ADDRESS);

        assertEq(globals.pendingGovernor(), SET_ADDRESS);
    }

}

contract SetSecurityAdminTests is BaseMapleGlobalsTest {

    function test_setSecurityAdmin_notGovernor() external {
        vm.expectRevert("MG:NOT_GOVERNOR");
        globals.setSecurityAdmin(SET_ADDRESS);
    }

    function test_setSecurityAdmin() external {
        assertEq(globals.securityAdmin(), address(0));

        vm.prank(GOVERNOR);
        globals.setSecurityAdmin(SET_ADDRESS);

        assertEq(globals.securityAdmin(), SET_ADDRESS);
    }

}

/***********************/
/*** Boolean Setters ***/
/***********************/

contract SetProtocolPauseTests is BaseMapleGlobalsTest {

    address SECURITY_ADMIN = address(new Address());

    function setUp() public override {
        super.setUp();

        vm.prank(GOVERNOR);
        globals.setSecurityAdmin(SECURITY_ADMIN);
    }

    function test_setProtocolPause_notSecurityAdmin() external {
        vm.expectRevert("MG:SPP:NOT_SECURITY_ADMIN");
        globals.setProtocolPause(true);
    }

    function test_setProtocolPause() external {
        assertTrue(!globals.protocolPaused());

        vm.prank(SECURITY_ADMIN);
        globals.setProtocolPause(true);

        assertTrue(globals.protocolPaused());

        vm.prank(SECURITY_ADMIN);
        globals.setProtocolPause(false);

        assertTrue(!globals.protocolPaused());
    }

}

/*************************/
/*** Allowlist Setters ***/
/*************************/

contract SetValidBorrowerTests is BaseMapleGlobalsTest {

    function test_setValidBorrower_notGovernor() external {
        vm.expectRevert("MG:NOT_GOVERNOR");
        globals.setValidBorrower(SET_ADDRESS, true);

        vm.prank(GOVERNOR);
        globals.setValidBorrower(SET_ADDRESS, true);
    }

    function test_setValidBorrower() external {
        vm.startPrank(GOVERNOR);

        assertTrue(!globals.isBorrower(SET_ADDRESS));

        globals.setValidBorrower(SET_ADDRESS, true);

        assertTrue(globals.isBorrower(SET_ADDRESS));

        globals.setValidBorrower(SET_ADDRESS, false);

        assertTrue(!globals.isBorrower(SET_ADDRESS));
    }

}

contract SetValidFactoryTests is BaseMapleGlobalsTest {

    function test_setValidFactory_notGovernor() external {
        vm.expectRevert("MG:NOT_GOVERNOR");
        globals.setValidFactory("TEST_FACTORY", SET_ADDRESS, true);

        vm.prank(GOVERNOR);
        globals.setValidFactory("TEST_FACTORY", SET_ADDRESS, true);
    }

    function test_setValidFactory() external {
        vm.startPrank(GOVERNOR);

        assertTrue(!globals.isFactory("TEST_FACTORY", SET_ADDRESS));

        globals.setValidFactory("TEST_FACTORY", SET_ADDRESS, true);

        assertTrue(globals.isFactory("TEST_FACTORY", SET_ADDRESS));

        globals.setValidFactory("TEST_FACTORY", SET_ADDRESS, false);

        assertTrue(!globals.isFactory("TEST_FACTORY", SET_ADDRESS));
    }

}

contract SetValidPoolAssetTests is BaseMapleGlobalsTest {

    function test_setValidPoolAsset_notGovernor() external {
        vm.expectRevert("MG:NOT_GOVERNOR");
        globals.setValidPoolAsset(SET_ADDRESS, true);

        vm.prank(GOVERNOR);
        globals.setValidPoolAsset(SET_ADDRESS, true);
    }

    function test_setValidPoolAsset() external {
        vm.startPrank(GOVERNOR);

        assertTrue(!globals.isPoolAsset(SET_ADDRESS));

        globals.setValidPoolAsset(SET_ADDRESS, true);

        assertTrue(globals.isPoolAsset(SET_ADDRESS));

        globals.setValidPoolAsset(SET_ADDRESS, false);

        assertTrue(!globals.isPoolAsset(SET_ADDRESS));
    }

}

contract SetValidPoolDeployer is BaseMapleGlobalsTest {

    function test_setValidDeployer_notGovernor() external {
        vm.expectRevert("MG:NOT_GOVERNOR");
        globals.setValidPoolDeployer(SET_ADDRESS, true);

        vm.prank(GOVERNOR);
        globals.setValidPoolDeployer(SET_ADDRESS, true);
    }

    function test_setValidDeployer() external {
        vm.startPrank(GOVERNOR);

        assertTrue(!globals.isPoolDeployer(SET_ADDRESS));

        globals.setValidPoolDeployer(SET_ADDRESS, true);

        assertTrue(globals.isPoolDeployer(SET_ADDRESS));

        globals.setValidPoolDeployer(SET_ADDRESS, false);

        assertTrue(!globals.isPoolDeployer(SET_ADDRESS));
    }
}

/*********************/
/*** Price Setters ***/
/*********************/

contract SetManualOverridePriceTests is BaseMapleGlobalsTest {

    address ASSET = address(new Address());

    function test_setManualOverridePrice_notGovernor() external {
        vm.expectRevert("MG:NOT_GOVERNOR");
        globals.setManualOverridePrice(ASSET, 100);

        vm.prank(GOVERNOR);
        globals.setManualOverridePrice(ASSET, 100);
    }

    function test_setManualOverridePrice() external {
        MockChainlinkOracle oracle = new MockChainlinkOracle();

        oracle.__setUpdatedAt(1);
        oracle.__setRoundId(1);
        oracle.__setAnsweredInRound(1);
        oracle.__setPrice(100);

        vm.prank(GOVERNOR);
        globals.setPriceOracle(ASSET, address(oracle));

        assertEq(globals.getLatestPrice(ASSET), 100);

        vm.prank(GOVERNOR);
        globals.setManualOverridePrice(ASSET, 200);

        assertEq(globals.getLatestPrice(ASSET), 200);
    }

}


/*********************/
/*** Cover Setters ***/
/*********************/

contract SetMaxCoverLiquidationPercentTests is BaseMapleGlobalsTest {

    function test_setMaxCoverLiquidationPercent_notGovernor() external {
        vm.expectRevert("MG:NOT_GOVERNOR");
        globals.setMaxCoverLiquidationPercent(SET_ADDRESS, 50_00);

        vm.prank(GOVERNOR);
        globals.setMaxCoverLiquidationPercent(SET_ADDRESS, 50_00);
    }

    function test_setMaxCoverLiquidationPercent_gt100() external {
        vm.startPrank(GOVERNOR);
        vm.expectRevert("MG:SMCLP:GT_100");
        globals.setMaxCoverLiquidationPercent(SET_ADDRESS, 1e18 + 1);

        globals.setMaxCoverLiquidationPercent(SET_ADDRESS, 1e18);
    }

    function test_setMaxCoverLiquidationPercent() external {
        vm.startPrank(GOVERNOR);

        assertEq(globals.maxCoverLiquidationPercent(SET_ADDRESS), 0);

        globals.setMaxCoverLiquidationPercent(SET_ADDRESS, 50_00);

        assertEq(globals.maxCoverLiquidationPercent(SET_ADDRESS), 50_00);
    }

}

contract SetMinCoverAmountTests is BaseMapleGlobalsTest {

    function test_setMinCoverAmount_notGovernor() external {
        vm.expectRevert("MG:NOT_GOVERNOR");
        globals.setMinCoverAmount(SET_ADDRESS, 1_000e6);

        vm.prank(GOVERNOR);
        globals.setMinCoverAmount(SET_ADDRESS, 1_000e6);
    }

    function test_setMinCoverAmount() external {
        vm.startPrank(GOVERNOR);

        assertEq(globals.minCoverAmount(SET_ADDRESS), 0);

        globals.setMinCoverAmount(SET_ADDRESS, 1_000e6);

        assertEq(globals.minCoverAmount(SET_ADDRESS), 1_000e6);
    }

}

/*******************/
/*** Fee Setters ***/
/*******************/

contract SetPlatformManagementFeeRateTests is BaseMapleGlobalsTest {

    address PM_ADDRESS = address(new Address());

    function test_setPlatformManagementFeeRate_notGovernor() external {
        vm.expectRevert("MG:NOT_GOVERNOR");
        globals.setPlatformManagementFeeRate(PM_ADDRESS, 0.2e18);

        vm.prank(GOVERNOR);
        globals.setPlatformManagementFeeRate(PM_ADDRESS, 0.2e18);
    }

    function test_setPlatformManagementFeeRate_outOfBounds() external {
        vm.startPrank(GOVERNOR);

        vm.expectRevert("MG:SPMFR:RATE_GT_100");
        globals.setPlatformManagementFeeRate(PM_ADDRESS, 1e18 + 1);

        globals.setPlatformManagementFeeRate(PM_ADDRESS, 1e18);
    }

    function test_setPlatformManagementFeeRate() external {
        assertEq(globals.platformManagementFeeRate(PM_ADDRESS), 0);

        vm.prank(GOVERNOR);
        globals.setPlatformManagementFeeRate(PM_ADDRESS, 0.2e18);

        assertEq(globals.platformManagementFeeRate(PM_ADDRESS), 0.2e18);
    }

}

contract SetPlatformOriginationFeeRateTests is BaseMapleGlobalsTest {

    address PM_ADDRESS = address(new Address());

    function test_setPlatformOriginationFeeRate_notGovernor() external {
        vm.expectRevert("MG:NOT_GOVERNOR");
        globals.setPlatformOriginationFeeRate(PM_ADDRESS, 0.2e18);

        vm.prank(GOVERNOR);
        globals.setPlatformOriginationFeeRate(PM_ADDRESS, 0.2e18);
    }

    function test_setPlatformOriginationFeeRate_outOfBounds() external {
        vm.startPrank(GOVERNOR);

        vm.expectRevert("MG:SPOFR:RATE_GT_100");
        globals.setPlatformOriginationFeeRate(PM_ADDRESS, 1e18 + 1);

        globals.setPlatformOriginationFeeRate(PM_ADDRESS, 1e18);
    }

    function test_setPlatformOriginationFeeRate() external {
        assertEq(globals.platformOriginationFeeRate(PM_ADDRESS), 0);

        vm.prank(GOVERNOR);
        globals.setPlatformOriginationFeeRate(PM_ADDRESS, 0.2e18);

        assertEq(globals.platformOriginationFeeRate(PM_ADDRESS), 0.2e18);
    }

}

contract SetPlatformServiceFeeRateTests is BaseMapleGlobalsTest {

    address PM_ADDRESS = address(new Address());

    function test_setPlatformServiceFeeRate_notGovernor() external {
        vm.expectRevert("MG:NOT_GOVERNOR");
        globals.setPlatformServiceFeeRate(PM_ADDRESS, 0.2e18);

        vm.prank(GOVERNOR);
        globals.setPlatformServiceFeeRate(PM_ADDRESS, 0.2e18);
    }

    function test_setPlatformServiceFeeRate_outOfBounds() external {
        vm.startPrank(GOVERNOR);

        vm.expectRevert("MG:SPSFR:RATE_GT_100");
        globals.setPlatformServiceFeeRate(PM_ADDRESS, 1e18 + 1);

        globals.setPlatformServiceFeeRate(PM_ADDRESS, 1e18);
    }

    function test_setPlatformServiceFeeRate() external {
        assertEq(globals.platformServiceFeeRate(PM_ADDRESS), 0);

        vm.prank(GOVERNOR);
        globals.setPlatformServiceFeeRate(PM_ADDRESS, 0.2e18);

        assertEq(globals.platformServiceFeeRate(PM_ADDRESS), 0.2e18);
    }

}

/*******************************/
/*** Pool Activation Setters ***/
/*******************************/

contract ActivatePoolTests is BaseMapleGlobalsTest {

    address admin = address(13);

    MockPoolManager manager = new MockPoolManager(admin);

    function test_activatePool_notGovernor() external {
        vm.expectRevert("MG:NOT_GOVERNOR");
        globals.activatePool(address(manager));

        vm.prank(GOVERNOR);
        globals.activatePool(address(manager));
    }

    function test_activatePool_success() external {
        assertEq(globals.ownedPoolManager(admin), address(0));

        vm.prank(GOVERNOR);
        globals.activatePool(address(manager));

        assertEq(globals.ownedPoolManager(admin), address(manager));
    }

}

/*********************/
/*** Range Setters ***/
/*********************/

contract SetRangeTests is BaseMapleGlobalsTest {

    address constant PM_ADDRESS = address(3);

    function test_setRange_notGovernor() external {
        vm.expectRevert("MG:NOT_GOVERNOR");
        globals.setRange(PM_ADDRESS, "LIQUIDITY_CAP", 1, 100_000_000e6);

        vm.prank(GOVERNOR);
        globals.setRange(PM_ADDRESS, "LIQUIDITY_CAP", 1, 100_000_000e6);
    }

    function test_setRange() external {
        assertEq(globals.minValue(PM_ADDRESS, "LIQUIDITY_CAP"), 0);
        assertEq(globals.maxValue(PM_ADDRESS, "LIQUIDITY_CAP"), 0);

        vm.prank(GOVERNOR);
        globals.setRange(PM_ADDRESS, "LIQUIDITY_CAP", 1, 100_000_000e6);

        assertEq(globals.minValue(PM_ADDRESS, "LIQUIDITY_CAP"), 1);
        assertEq(globals.maxValue(PM_ADDRESS, "LIQUIDITY_CAP"), 100_000_000e6);
    }

}

/************************/
/*** Timelock Setters ***/
/************************/

contract SetMinTimelockTests is BaseMapleGlobalsTest {

    function test_setMinTimelock_notGovernor() external {
        vm.expectRevert("MG:NOT_GOVERNOR");
        globals.setMinTimelock("WITHDRAWAL_MANAGER:SET_COOLDOWN", 20 days);

        vm.prank(GOVERNOR);
        globals.setMinTimelock("WITHDRAWAL_MANAGER:SET_COOLDOWN", 20 days);
    }

    function test_setMinTimelock() external {
        assertEq(globals.minTimelock("WITHDRAWAL_MANAGER:SET_COOLDOWN"), 0);

        vm.prank(GOVERNOR);
        globals.setMinTimelock("WITHDRAWAL_MANAGER:SET_COOLDOWN", 20 days);

        assertEq(globals.minTimelock("WITHDRAWAL_MANAGER:SET_COOLDOWN"), 20 days);
    }

}

/**************************/
/*** Schedule Functions ***/
/**************************/

contract ScheduleCallTests is BaseMapleGlobalsTest {

    function test_scheduleCall() external {
        vm.startPrank(GOVERNOR);
        vm.warp(10000);

        assertEq(globals.callSchedule("WITHDRAWAL_MANAGER:SET_COOLDOWN", GOVERNOR), 0);

        globals.scheduleCall("WITHDRAWAL_MANAGER:SET_COOLDOWN");

        assertEq(globals.callSchedule("WITHDRAWAL_MANAGER:SET_COOLDOWN", GOVERNOR), block.timestamp);
    }

}

/************************/
/*** Getter Functions ***/
/************************/

contract GetLatestPriceTests is BaseMapleGlobalsTest {

    address ASSET = address(new Address());

    MockChainlinkOracle oracle = new MockChainlinkOracle();

    function setUp() public override {
        super.setUp();

        vm.prank(GOVERNOR);
        globals.setPriceOracle(ASSET, address(oracle));
    }

    function test_getLatestPrice_roundNotComplete() external {
        vm.expectRevert("MG:GLP:ROUND_NOT_COMPLETE");
        globals.getLatestPrice(ASSET);
    }

    function test_getLatestPrice_staleData() external {
        oracle.__setUpdatedAt(1);
        oracle.__setRoundId(1);  // `answeredInRound_` is 0.

        vm.expectRevert("MG:GLP:STALE_DATA");
        globals.getLatestPrice(ASSET);
    }

    function test_getLatestPrice_zeroPrice() external {
        oracle.__setUpdatedAt(1);
        oracle.__setRoundId(1);
        oracle.__setAnsweredInRound(1);

        vm.expectRevert("MG:GLP:ZERO_PRICE");
        globals.getLatestPrice(ASSET);
    }

    function test_getLatestPrice() external {
        oracle.__setUpdatedAt(1);
        oracle.__setRoundId(1);
        oracle.__setAnsweredInRound(1);

        oracle.__setPrice(100);

        assertEq(globals.getLatestPrice(ASSET), 100);

        oracle.__setPrice(200);

        assertEq(globals.getLatestPrice(ASSET), 200);
    }

    function test_getLatestPrice_manualOverride() external {
        oracle.__setUpdatedAt(1);
        oracle.__setRoundId(1);
        oracle.__setAnsweredInRound(1);

        oracle.__setPrice(100);

        assertEq(globals.getLatestPrice(ASSET), 100);

        vm.prank(GOVERNOR);
        globals.setManualOverridePrice(ASSET, 200);

        assertEq(globals.getLatestPrice(ASSET), 200);

        vm.prank(GOVERNOR);
        globals.setManualOverridePrice(ASSET, 0);

        assertEq(globals.getLatestPrice(ASSET), 100);
    }

}

