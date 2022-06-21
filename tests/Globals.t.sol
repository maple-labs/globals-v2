// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.7;

import { TestUtils } from "../modules/contract-test-utils/contracts/test.sol";

import { Globals } from "../contracts/Globals.sol";

contract BaseGlobalsTest is TestUtils {

    address constant NOT_GOVERNOR = address(1);
    address constant SET_ADDRESS  = address(2);

    address GOVERNOR;

    Globals globals;

    function setUp() public virtual {
        GOVERNOR = address(this);

        globals = new Globals(GOVERNOR);
    }

}

/***********************/
/*** Address Setters ***/
/***********************/

contract SetMapleTreasuryTests is BaseGlobalsTest {

    function test_setMapleTreasury_notGovernor() external {
        vm.startPrank(NOT_GOVERNOR);
        vm.expectRevert("G:NOT_GOV");
        globals.setMapleTreasury(SET_ADDRESS);
        vm.stopPrank();

        globals.setMapleTreasury(SET_ADDRESS);
    }

    function test_setMapleTreasury() external {
        assertEq(globals.mapleTreasury(), address(0));

        globals.setMapleTreasury(SET_ADDRESS);

        assertEq(globals.mapleTreasury(), SET_ADDRESS);
    }

}

/*************************/
/*** Allowlist Setters ***/
/*************************/

contract SetValidBorrowerTests is BaseGlobalsTest {

    function test_setValidBorrower_notGovernor() external {
        vm.startPrank(NOT_GOVERNOR);
        vm.expectRevert("G:NOT_GOV");
        globals.setValidBorrower(SET_ADDRESS, true);
        vm.stopPrank();

        globals.setValidBorrower(SET_ADDRESS, true);
    }

    function test_setValidBorrower() external {
        assertTrue(!globals.isBorrower(SET_ADDRESS));

        globals.setValidBorrower(SET_ADDRESS, true);

        assertTrue(globals.isBorrower(SET_ADDRESS));

        globals.setValidBorrower(SET_ADDRESS, false);

        assertTrue(!globals.isBorrower(SET_ADDRESS));
    }

}

contract SetValidFactoryTests is BaseGlobalsTest {

    function test_setValidFactory_notGovernor() external {
        vm.startPrank(NOT_GOVERNOR);
        vm.expectRevert("G:NOT_GOV");
        globals.setValidFactory("TEST_FACTORY", SET_ADDRESS, true);
        vm.stopPrank();

        globals.setValidFactory("TEST_FACTORY", SET_ADDRESS, true);
    }

    function test_setValidFactory() external {
        assertTrue(!globals.isFactory("TEST_FACTORY", SET_ADDRESS));

        globals.setValidFactory("TEST_FACTORY", SET_ADDRESS, true);

        assertTrue(globals.isFactory("TEST_FACTORY", SET_ADDRESS));

        globals.setValidFactory("TEST_FACTORY", SET_ADDRESS, false);

        assertTrue(!globals.isFactory("TEST_FACTORY", SET_ADDRESS));
    }

}

contract SetValidPoolAssetTests is BaseGlobalsTest {

    function test_setValidPoolAsset_notGovernor() external {
        vm.startPrank(NOT_GOVERNOR);
        vm.expectRevert("G:NOT_GOV");
        globals.setValidPoolAsset(SET_ADDRESS, true);
        vm.stopPrank();

        globals.setValidPoolAsset(SET_ADDRESS, true);
    }

    function test_setValidPoolAsset() external {
        assertTrue(!globals.isPoolAsset(SET_ADDRESS));

        globals.setValidPoolAsset(SET_ADDRESS, true);

        assertTrue(globals.isPoolAsset(SET_ADDRESS));

        globals.setValidPoolAsset(SET_ADDRESS, false);

        assertTrue(!globals.isPoolAsset(SET_ADDRESS));
    }

}

contract SetValidPoolCoverAssetTests is BaseGlobalsTest {

    function test_setValidPoolCoverAsset_notGovernor() external {
        vm.startPrank(NOT_GOVERNOR);
        vm.expectRevert("G:NOT_GOV");
        globals.setValidPoolCoverAsset(SET_ADDRESS, true);
        vm.stopPrank();

        globals.setValidPoolCoverAsset(SET_ADDRESS, true);
    }

    function test_setValidPoolCoverAsset() external {
        assertTrue(!globals.isPoolCoverAsset(SET_ADDRESS));

        globals.setValidPoolCoverAsset(SET_ADDRESS, true);

        assertTrue(globals.isPoolCoverAsset(SET_ADDRESS));

        globals.setValidPoolCoverAsset(SET_ADDRESS, false);

        assertTrue(!globals.isPoolCoverAsset(SET_ADDRESS));
    }

}

/*******************/
/*** Fee Setters ***/
/*******************/

contract SetAdminFeeSplitTests is BaseGlobalsTest {

    address constant POOL_ADDRESS = address(3);

    function test_setAdminFeeSplit_notGovernor() external {
        vm.startPrank(NOT_GOVERNOR);
        vm.expectRevert("G:NOT_GOV");
        globals.setAdminFeeSplit(POOL_ADDRESS, 20_00);
        vm.stopPrank();

        globals.setAdminFeeSplit(POOL_ADDRESS, 20_00);
    }

    function test_setAdminFeeSplit_outOfBounds() external {
        vm.expectRevert("G:SAFS:SPLIT_GT_100");
        globals.setAdminFeeSplit(POOL_ADDRESS, 100_01);

        globals.setAdminFeeSplit(POOL_ADDRESS, 100_00);
    }

    function test_setAdminFeeSplit() external {
        assertEq(globals.adminFeeSplit(POOL_ADDRESS), 0);

        globals.setAdminFeeSplit(POOL_ADDRESS, 20_00);

        assertEq(globals.adminFeeSplit(POOL_ADDRESS), 20_00);
    }

}

contract SetManagementFeeSplitTests is BaseGlobalsTest {

    address constant POOL_ADDRESS = address(3);

    function test_setManagementFeeSplit_notGovernor() external {
        vm.startPrank(NOT_GOVERNOR);
        vm.expectRevert("G:NOT_GOV");
        globals.setManagementFeeSplit(POOL_ADDRESS, 20_00);
        vm.stopPrank();

        globals.setManagementFeeSplit(POOL_ADDRESS, 20_00);
    }

    function test_setManagementFeeSplit_outOfBounds() external {
        vm.expectRevert("G:SMFS:SPLIT_GT_100");
        globals.setManagementFeeSplit(POOL_ADDRESS, 100_01);

        globals.setManagementFeeSplit(POOL_ADDRESS, 100_00);
    }

    function test_setManagementFeeSplit() external {
        assertEq(globals.managementFeeSplit(POOL_ADDRESS), 0);

        globals.setManagementFeeSplit(POOL_ADDRESS, 20_00);

        assertEq(globals.managementFeeSplit(POOL_ADDRESS), 20_00);
    }

}

contract SetOriginationFeeSplitTests is BaseGlobalsTest {

    address constant POOL_ADDRESS = address(3);

    function test_setOriginationFeeSplit_notGovernor() external {
        vm.startPrank(NOT_GOVERNOR);
        vm.expectRevert("G:NOT_GOV");
        globals.setOriginationFeeSplit(POOL_ADDRESS, 20_00);
        vm.stopPrank();

        globals.setOriginationFeeSplit(POOL_ADDRESS, 20_00);
    }

    function test_setOriginationFeeSplit_outOfBounds() external {
        vm.expectRevert("G:SOFS:SPLIT_GT_100");
        globals.setOriginationFeeSplit(POOL_ADDRESS, 100_01);

        globals.setOriginationFeeSplit(POOL_ADDRESS, 100_00);
    }

    function test_setOriginationFeeSplit() external {
        assertEq(globals.originationFeeSplit(POOL_ADDRESS), 0);

        globals.setOriginationFeeSplit(POOL_ADDRESS, 20_00);

        assertEq(globals.originationFeeSplit(POOL_ADDRESS), 20_00);
    }

}

contract SetPlatformFeeTests is BaseGlobalsTest {

    address constant POOL_ADDRESS = address(3);

    function test_setPlatformFee_notGovernor() external {
        vm.startPrank(NOT_GOVERNOR);
        vm.expectRevert("G:NOT_GOV");
        globals.setPlatformFee(POOL_ADDRESS, 20_00);
        vm.stopPrank();

        globals.setPlatformFee(POOL_ADDRESS, 20_00);
    }

    function test_setPlatformFee_outOfBounds() external {
        vm.expectRevert("G:SPF:FEE_GT_100");
        globals.setPlatformFee(POOL_ADDRESS, 100_01);

        // globals.setPlatformFee(POOL_ADDRESS, 100_00);
    }

    function test_setPlatformFee() external {
        assertEq(globals.platformFee(POOL_ADDRESS), 0);

        globals.setPlatformFee(POOL_ADDRESS, 20_00);

        assertEq(globals.platformFee(POOL_ADDRESS), 20_00);
    }

}

/*********************/
/*** Range Setters ***/
/*********************/

contract SetRangeTests is BaseGlobalsTest {

    address constant POOL_ADDRESS = address(3);

    function test_setRange_notGovernor() external {
        vm.startPrank(NOT_GOVERNOR);
        vm.expectRevert("G:NOT_GOV");
        globals.setRange(POOL_ADDRESS, "LIQUIDITY_CAP", 1, 100_000_000e6);
        vm.stopPrank();

        globals.setRange(POOL_ADDRESS, "LIQUIDITY_CAP", 1, 100_000_000e6);
    }

    function test_setRange() external {
        assertEq(globals.minValue(POOL_ADDRESS, "LIQUIDITY_CAP"), 0);
        assertEq(globals.maxValue(POOL_ADDRESS, "LIQUIDITY_CAP"), 0);

        globals.setRange(POOL_ADDRESS, "LIQUIDITY_CAP", 1, 100_000_000e6);

        assertEq(globals.minValue(POOL_ADDRESS, "LIQUIDITY_CAP"), 1);
        assertEq(globals.maxValue(POOL_ADDRESS, "LIQUIDITY_CAP"), 100_000_000e6);
    }

}

/************************/
/*** Timelock Setters ***/
/************************/

contract SetMinTimelockTests is BaseGlobalsTest {

    function test_setMinTimelock_notGovernor() external {
        vm.startPrank(NOT_GOVERNOR);
        vm.expectRevert("G:NOT_GOV");
        globals.setMinTimelock("WITHDRAWAL_MANAGER:SET_COOLDOWN", 20 days);
        vm.stopPrank();

        globals.setMinTimelock("WITHDRAWAL_MANAGER:SET_COOLDOWN", 20 days);
    }

    function test_setMinTimelock() external {
        assertEq(globals.minTimelock("WITHDRAWAL_MANAGER:SET_COOLDOWN"), 0);

        globals.setMinTimelock("WITHDRAWAL_MANAGER:SET_COOLDOWN", 20 days);

        assertEq(globals.minTimelock("WITHDRAWAL_MANAGER:SET_COOLDOWN"), 20 days);
    }

}

/**************************/
/*** Schedule Functions ***/
/**************************/

contract ScheduleCallTests is BaseGlobalsTest {

    function test_scheduleCall() external {
        vm.warp(10000);  // Warp to non-zero timestamp

        assertEq(globals.callSchedule("WITHDRAWAL_MANAGER:SET_COOLDOWN", address(this)), 0);

        globals.scheduleCall("WITHDRAWAL_MANAGER:SET_COOLDOWN");

        assertEq(globals.callSchedule("WITHDRAWAL_MANAGER:SET_COOLDOWN", address(this)), block.timestamp);
    }

}

