// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.7;

import { Address, TestUtils }  from "../modules/contract-test-utils/contracts/test.sol";
import { NonTransparentProxy } from "../modules/non-transparent-proxy/contracts/NonTransparentProxy.sol";

import { MapleGlobals } from "../contracts/MapleGlobals.sol";

import { MockPool, MockPoolManager } from "./mocks/Mocks.sol";

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

/*******************/
/*** Fee Setters ***/
/*******************/

contract SetAdminFeeSplitTests is BaseMapleGlobalsTest {

    address constant POOL_ADDRESS = address(3);

    function test_setAdminFeeSplit_notGovernor() external {
        vm.expectRevert("MG:NOT_GOVERNOR");
        globals.setAdminFeeSplit(POOL_ADDRESS, 20_00);

        vm.prank(GOVERNOR);
        globals.setAdminFeeSplit(POOL_ADDRESS, 20_00);
    }

    function test_setAdminFeeSplit_outOfBounds() external {
        vm.startPrank(GOVERNOR);

        vm.expectRevert("MG:SAFS:SPLIT_GT_100");
        globals.setAdminFeeSplit(POOL_ADDRESS, 100_01);

        globals.setAdminFeeSplit(POOL_ADDRESS, 100_00);
    }

    function test_setAdminFeeSplit() external {
        assertEq(globals.adminFeeSplit(POOL_ADDRESS), 0);

        vm.prank(GOVERNOR);
        globals.setAdminFeeSplit(POOL_ADDRESS, 20_00);

        assertEq(globals.adminFeeSplit(POOL_ADDRESS), 20_00);
    }

}

contract SetManagementFeeSplitTests is BaseMapleGlobalsTest {

    address constant POOL_ADDRESS = address(3);

    function test_setManagementFeeSplit_notGovernor() external {
        vm.expectRevert("MG:NOT_GOVERNOR");
        globals.setManagementFeeSplit(POOL_ADDRESS, 20_00);

        vm.prank(GOVERNOR);
        globals.setManagementFeeSplit(POOL_ADDRESS, 20_00);
    }

    function test_setManagementFeeSplit_outOfBounds() external {
        vm.startPrank(GOVERNOR);

        vm.expectRevert("MG:SMFS:SPLIT_GT_100");
        globals.setManagementFeeSplit(POOL_ADDRESS, 100_01);

        globals.setManagementFeeSplit(POOL_ADDRESS, 100_00);
    }

    function test_setManagementFeeSplit() external {
        assertEq(globals.managementFeeSplit(POOL_ADDRESS), 0);

        vm.prank(GOVERNOR);
        globals.setManagementFeeSplit(POOL_ADDRESS, 20_00);

        assertEq(globals.managementFeeSplit(POOL_ADDRESS), 20_00);
    }

}

contract SetOriginationFeeSplitTests is BaseMapleGlobalsTest {

    address constant POOL_ADDRESS = address(3);

    function test_setOriginationFeeSplit_notGovernor() external {
        vm.expectRevert("MG:NOT_GOVERNOR");
        globals.setOriginationFeeSplit(POOL_ADDRESS, 20_00);

        vm.prank(GOVERNOR);
        globals.setOriginationFeeSplit(POOL_ADDRESS, 20_00);
    }

    function test_setOriginationFeeSplit_outOfBounds() external {
        vm.startPrank(GOVERNOR);

        vm.expectRevert("MG:SOFS:SPLIT_GT_100");
        globals.setOriginationFeeSplit(POOL_ADDRESS, 100_01);

        globals.setOriginationFeeSplit(POOL_ADDRESS, 100_00);
    }

    function test_setOriginationFeeSplit() external {
        assertEq(globals.originationFeeSplit(POOL_ADDRESS), 0);

        vm.prank(GOVERNOR);
        globals.setOriginationFeeSplit(POOL_ADDRESS, 20_00);

        assertEq(globals.originationFeeSplit(POOL_ADDRESS), 20_00);
    }

}

contract SetPlatformFeeTests is BaseMapleGlobalsTest {

    address constant POOL_ADDRESS = address(3);

    function test_setPlatformFee_notGovernor() external {
        vm.expectRevert("MG:NOT_GOVERNOR");
        globals.setPlatformFee(POOL_ADDRESS, 20_00);

        vm.prank(GOVERNOR);
        globals.setPlatformFee(POOL_ADDRESS, 20_00);
    }

    function test_setPlatformFee_outOfBounds() external {
        vm.startPrank(GOVERNOR);

        vm.expectRevert("MG:SPF:FEE_GT_100");
        globals.setPlatformFee(POOL_ADDRESS, 100_01);

        globals.setPlatformFee(POOL_ADDRESS, 100_00);
    }

    function test_setPlatformFee() external {
        assertEq(globals.platformFee(POOL_ADDRESS), 0);

        vm.prank(GOVERNOR);
        globals.setPlatformFee(POOL_ADDRESS, 20_00);

        assertEq(globals.platformFee(POOL_ADDRESS), 20_00);
    }

}

/*******************************/
/*** Pool Activation Setters ***/
/*******************************/

contract ActivatePoolTests is BaseMapleGlobalsTest {

    address admin = address(13);

    MockPoolManager manager = new MockPoolManager(admin);
    MockPool        pool    = new MockPool(address(manager));

    function test_activatePool_notGovernor() external {
        vm.expectRevert("MG:NOT_GOVERNOR");
        globals.activatePool(address(pool));

        vm.prank(GOVERNOR);
        globals.activatePool(address(pool));
    }

    function test_activatePool_success() external {
        assertEq(globals.ownedPool(admin), address(0));

        vm.prank(GOVERNOR);
        globals.activatePool(address(pool));

        assertEq(globals.ownedPool(admin), address(pool));
    }

}

/*********************/
/*** Range Setters ***/
/*********************/

contract SetRangeTests is BaseMapleGlobalsTest {

    address constant POOL_ADDRESS = address(3);

    function test_setRange_notGovernor() external {
        vm.expectRevert("MG:NOT_GOVERNOR");
        globals.setRange(POOL_ADDRESS, "LIQUIDITY_CAP", 1, 100_000_000e6);

        vm.prank(GOVERNOR);
        globals.setRange(POOL_ADDRESS, "LIQUIDITY_CAP", 1, 100_000_000e6);
    }

    function test_setRange() external {
        assertEq(globals.minValue(POOL_ADDRESS, "LIQUIDITY_CAP"), 0);
        assertEq(globals.maxValue(POOL_ADDRESS, "LIQUIDITY_CAP"), 0);

        vm.prank(GOVERNOR);
        globals.setRange(POOL_ADDRESS, "LIQUIDITY_CAP", 1, 100_000_000e6);

        assertEq(globals.minValue(POOL_ADDRESS, "LIQUIDITY_CAP"), 1);
        assertEq(globals.maxValue(POOL_ADDRESS, "LIQUIDITY_CAP"), 100_000_000e6);
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

