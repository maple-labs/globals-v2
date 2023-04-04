// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.7;

import { Address, TestUtils }  from "../modules/contract-test-utils/contracts/test.sol";
import { NonTransparentProxy } from "../modules/non-transparent-proxy/contracts/NonTransparentProxy.sol";

import { MapleGlobals } from "../contracts/MapleGlobals.sol";

import { MockChainlinkOracle, MockPoolManager } from "./mocks/Mocks.sol";

contract BaseMapleGlobalsTest is TestUtils {

    address internal GOVERNOR    = address(new Address());
    address internal SET_ADDRESS = address(new Address());

    address internal implementation;

    MapleGlobals internal globals;

    function setUp() public virtual {
        implementation = address(new MapleGlobals());
        globals        = MapleGlobals(address(new NonTransparentProxy(GOVERNOR, address(implementation))));
    }

}

/******************************************************************************************************************************************/
/*** Governor Transfer Functions                                                                                                        ***/
/******************************************************************************************************************************************/

contract TransferGovernorTests is BaseMapleGlobalsTest {

    bytes32 internal constant ADMIN_SLOT = bytes32(uint256(keccak256("eip1967.proxy.admin")) - 1);

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

/******************************************************************************************************************************************/
/*** Global Setters                                                                                                                     ***/
/******************************************************************************************************************************************/

contract ActivatePoolTests is BaseMapleGlobalsTest {

    address internal admin = address(new Address());

    MockPoolManager internal manager = new MockPoolManager(admin);

    function test_activatePoolManager_notGovernor() external {
        vm.expectRevert("MG:NOT_GOVERNOR");
        globals.activatePoolManager(address(manager));

        vm.prank(GOVERNOR);
        globals.activatePoolManager(address(manager));
    }

    function test_activatePoolManager_alreadyOwns() external {
        vm.prank(GOVERNOR);
        globals.activatePoolManager(address(manager));

        vm.prank(GOVERNOR);
        vm.expectRevert("MG:APM:ALREADY_OWNS");
        globals.activatePoolManager(address(manager));
    }

    function test_activatePoolManager_success() external {
        assertEq(globals.ownedPoolManager(admin), address(0));

        vm.prank(GOVERNOR);
        globals.activatePoolManager(address(manager));

        assertEq(globals.ownedPoolManager(admin), address(manager));
    }

}

contract SetMapleTreasuryTests is BaseMapleGlobalsTest {

    function test_setMapleTreasury_notGovernor() external {
        vm.expectRevert("MG:NOT_GOVERNOR");
        globals.setMapleTreasury(SET_ADDRESS);
    }

    function test_setMapleTreasury_zeroAddressCheck() external {
        vm.startPrank(GOVERNOR);
        vm.expectRevert("MG:SMT:ZERO_ADDRESS");
        globals.setMapleTreasury(address(0));
    }

    function test_setMapleTreasury() external {
        assertEq(globals.mapleTreasury(), address(0));

        vm.prank(GOVERNOR);
        globals.setMapleTreasury(SET_ADDRESS);

        assertEq(globals.mapleTreasury(), SET_ADDRESS);
    }

}

contract SetMigrationAdminTests is BaseMapleGlobalsTest {

    function test_setMigrationAdmin_notGovernor() external {
        vm.expectRevert("MG:NOT_GOVERNOR");
        globals.setMigrationAdmin(SET_ADDRESS);
    }

    function test_setMigrationAdmin() external {
        assertEq(globals.migrationAdmin(), address(0));

        vm.prank(GOVERNOR);
        globals.setMigrationAdmin(SET_ADDRESS);

        assertEq(globals.migrationAdmin(), SET_ADDRESS);
    }

}

contract SetPriceOracleTests is BaseMapleGlobalsTest {

    address internal ASSET = address(new Address());

    function test_setPriceOracle_notGovernor() external {
        vm.expectRevert("MG:NOT_GOVERNOR");
        globals.setPriceOracle(ASSET, SET_ADDRESS);
    }

    function test_setPriceOracle_zeroAddressCheck() external {
        vm.startPrank(GOVERNOR);

        vm.expectRevert("MG:SPO:ZERO_ADDRESS");
        globals.setPriceOracle(ASSET, address(0));

        vm.expectRevert("MG:SPO:ZERO_ADDRESS");
        globals.setPriceOracle(address(0), SET_ADDRESS);

        vm.expectRevert("MG:SPO:ZERO_ADDRESS");
        globals.setPriceOracle(address(0), address(0));
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

    function test_setSecurityAdmin_zeroAddressCheck() external {
        vm.startPrank(GOVERNOR);
        vm.expectRevert("MG:SSA:ZERO_ADDRESS");
        globals.setSecurityAdmin(address(0));
    }

    function test_setSecurityAdmin() external {
        assertEq(globals.securityAdmin(), address(0));

        vm.prank(GOVERNOR);
        globals.setSecurityAdmin(SET_ADDRESS);

        assertEq(globals.securityAdmin(), SET_ADDRESS);
    }

}

contract SetDefaultTimelockParametersTests is BaseMapleGlobalsTest {

    function test_setDefaultTimelockParameters_notGovernor() external {
        vm.expectRevert("MG:NOT_GOVERNOR");
        globals.setDefaultTimelockParameters(0, 0);
    }

    function test_setDefaultTimelockParameters() external {
        vm.prank(GOVERNOR);
        globals.setDefaultTimelockParameters(1, 2);

        ( uint128 delay, uint128 duration ) = globals.defaultTimelockParameters();

        assertEq(delay,    1);
        assertEq(duration, 2);
    }

}

/******************************************************************************************************************************************/
/*** Boolean Setters                                                                                                                    ***/
/******************************************************************************************************************************************/

contract SetContactPauseTests is BaseMapleGlobalsTest {

    address internal CONTRACT       = address(new Address());
    address internal SECURITY_ADMIN = address(new Address());

    function setUp() public override {
        super.setUp();

        vm.prank(GOVERNOR);
        globals.setSecurityAdmin(SECURITY_ADMIN);
    }

    function test_setContactPause_notAuthorized() external {
        vm.expectRevert("MG:SCP:NO_AUTH");
        globals.setContactPause(CONTRACT, true);
    }

    function test_setContactPause_asGovernor() external {
        assertTrue(!globals.isContractPaused(CONTRACT));

        vm.prank(GOVERNOR);
        globals.setContactPause(CONTRACT, true);

        assertTrue(globals.isContractPaused(CONTRACT));

        vm.prank(GOVERNOR);
        globals.setContactPause(CONTRACT, false);

        assertTrue(!globals.isContractPaused(CONTRACT));
    }

    function test_setContactPause_asSecurityAdmin() external {
        assertTrue(!globals.isContractPaused(CONTRACT));

        vm.prank(SECURITY_ADMIN);
        globals.setContactPause(CONTRACT, true);

        assertTrue(globals.isContractPaused(CONTRACT));

        vm.prank(SECURITY_ADMIN);
        globals.setContactPause(CONTRACT, false);

        assertTrue(!globals.isContractPaused(CONTRACT));
    }

}

contract SetFunctionUnpauseTests is BaseMapleGlobalsTest {

    address internal CONTRACT       = address(new Address());
    address internal SECURITY_ADMIN = address(new Address());

    bytes4 internal SIG = bytes4(0x12345678);

    function setUp() public override {
        super.setUp();

        vm.prank(GOVERNOR);
        globals.setSecurityAdmin(SECURITY_ADMIN);
    }

    function test_setContactPause_notAuthorized() external {
        vm.expectRevert("MG:SFU:NO_AUTH");
        globals.setFunctionUnpause(CONTRACT, SIG, true);
    }

    function test_setContactPause_asGovernor() external {
        assertTrue(!globals.isFunctionUnpaused(CONTRACT, SIG));

        vm.prank(GOVERNOR);
        globals.setFunctionUnpause(CONTRACT, SIG, true);

        assertTrue(globals.isFunctionUnpaused(CONTRACT, SIG));

        vm.prank(GOVERNOR);
        globals.setFunctionUnpause(CONTRACT, SIG, false);

        assertTrue(!globals.isFunctionUnpaused(CONTRACT, SIG));
    }

    function test_setContactPause_asSecurityAdmin() external {
        assertTrue(!globals.isFunctionUnpaused(CONTRACT, SIG));

        vm.prank(SECURITY_ADMIN);
        globals.setFunctionUnpause(CONTRACT, SIG, true);

        assertTrue(globals.isFunctionUnpaused(CONTRACT, SIG));

        vm.prank(SECURITY_ADMIN);
        globals.setFunctionUnpause(CONTRACT, SIG, false);

        assertTrue(!globals.isFunctionUnpaused(CONTRACT, SIG));
    }

}

contract SetProtocolPauseTests is BaseMapleGlobalsTest {

    address internal SECURITY_ADMIN = address(new Address());

    function setUp() public override {
        super.setUp();

        vm.prank(GOVERNOR);
        globals.setSecurityAdmin(SECURITY_ADMIN);
    }

    function test_setProtocolPause_notAuthorized() external {
        vm.expectRevert("MG:SPP:NO_AUTH");
        globals.setProtocolPause(true);
    }

    function test_setProtocolPause_asGovernor() external {
        assertTrue(!globals.protocolPaused());

        vm.prank(GOVERNOR);
        globals.setProtocolPause(true);

        assertTrue(globals.protocolPaused());

        vm.prank(GOVERNOR);
        globals.setProtocolPause(false);

        assertTrue(!globals.protocolPaused());
    }

    function test_setProtocolPause_asSecurityAdmin() external {
        assertTrue(!globals.protocolPaused());

        vm.prank(SECURITY_ADMIN);
        globals.setProtocolPause(true);

        assertTrue(globals.protocolPaused());

        vm.prank(SECURITY_ADMIN);
        globals.setProtocolPause(false);

        assertTrue(!globals.protocolPaused());
    }

}

/******************************************************************************************************************************************/
/*** Allowlist Setters                                                                                                                  ***/
/******************************************************************************************************************************************/

contract SetCanDeployTests is BaseMapleGlobalsTest {

    address FACTORY = address(new Address());

    function test_setCanDeploy_notGovernor() external {
        vm.expectRevert("MG:NOT_GOVERNOR");
        globals.setCanDeploy(FACTORY, SET_ADDRESS, true);
    }

    function test_setCanDeploy() external {
        assertTrue(!globals.canDeployFrom(FACTORY, SET_ADDRESS));

        vm.prank(GOVERNOR);
        globals.setCanDeploy(FACTORY, SET_ADDRESS, true);

        assertTrue(globals.canDeployFrom(FACTORY, SET_ADDRESS));

        vm.prank(GOVERNOR);
        globals.setCanDeploy(FACTORY, SET_ADDRESS, false);

        assertTrue(!globals.canDeployFrom(FACTORY, SET_ADDRESS));
    }

}

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

contract SetValidCollateralTests is BaseMapleGlobalsTest {

    function test_setValidCollateral_notGovernor() external {
        vm.expectRevert("MG:NOT_GOVERNOR");
        globals.setValidCollateralAsset(SET_ADDRESS, true);

        vm.prank(GOVERNOR);
        globals.setValidCollateralAsset(SET_ADDRESS, true);
    }

    function test_setValidCollateral() external {
        vm.startPrank(GOVERNOR);

        assertTrue(!globals.isCollateralAsset(SET_ADDRESS));

        globals.setValidCollateralAsset(SET_ADDRESS, true);

        assertTrue(globals.isCollateralAsset(SET_ADDRESS));

        globals.setValidCollateralAsset(SET_ADDRESS, false);

        assertTrue(!globals.isCollateralAsset(SET_ADDRESS));
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

        assertTrue(globals.isFactory("TEST_FACTORY",    SET_ADDRESS));
        assertTrue(globals.isInstanceOf("TEST_FACTORY", SET_ADDRESS));

        globals.setValidFactory("TEST_FACTORY", SET_ADDRESS, false);

        assertTrue(!globals.isFactory("TEST_FACTORY",    SET_ADDRESS));
        assertTrue(!globals.isInstanceOf("TEST_FACTORY", SET_ADDRESS));
    }

}

contract SetValidInstanceOfTests is BaseMapleGlobalsTest {

    function test_setValidInstanceOf_notGovernor() external {
        vm.expectRevert("MG:NOT_GOVERNOR");
        globals.setValidInstanceOf("TEST_INSTANCE", SET_ADDRESS, true);

        vm.prank(GOVERNOR);
        globals.setValidInstanceOf("TEST_INSTANCE", SET_ADDRESS, true);
    }

    function test_setValidInstanceOf() external {
        vm.startPrank(GOVERNOR);

        assertTrue(!globals.isInstanceOf("TEST_INSTANCE", SET_ADDRESS));
        assertTrue(!globals.isFactory("TEST_INSTANCE",    SET_ADDRESS));  // Backwards compatibility

        globals.setValidInstanceOf("TEST_INSTANCE", SET_ADDRESS, true);

        assertTrue(globals.isInstanceOf("TEST_INSTANCE", SET_ADDRESS));
        assertTrue(globals.isFactory("TEST_INSTANCE",    SET_ADDRESS));  // Backwards compatibility

        globals.setValidInstanceOf("TEST_INSTANCE", SET_ADDRESS, false);

        assertTrue(!globals.isInstanceOf("TEST_INSTANCE", SET_ADDRESS));
        assertTrue(!globals.isFactory("TEST_INSTANCE",    SET_ADDRESS));  // Backwards compatibility
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

contract SetValidPoolDelegate is BaseMapleGlobalsTest {

    function test_setValidPoolDelegate_notGovernor() external {
        vm.expectRevert("MG:NOT_GOVERNOR");
        globals.setValidPoolDelegate(SET_ADDRESS, true);

        vm.prank(GOVERNOR);
        globals.setValidPoolDelegate(SET_ADDRESS, true);
    }

    function test_setValidPoolDelegate() external {
        vm.startPrank(GOVERNOR);

        assertTrue(!globals.isPoolDelegate(SET_ADDRESS));

        globals.setValidPoolDelegate(SET_ADDRESS, true);

        assertTrue(globals.isPoolDelegate(SET_ADDRESS));

        globals.setValidPoolDelegate(SET_ADDRESS, false);

        assertTrue(!globals.isPoolDelegate(SET_ADDRESS));
    }

}

/******************************************************************************************************************************************/
/*** Price Getters                                                                                                                      ***/
/******************************************************************************************************************************************/

contract SetManualOverridePriceTests is BaseMapleGlobalsTest {

    address internal ASSET = address(new Address());

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

/******************************************************************************************************************************************/
/*** Cover Setters                                                                                                                      ***/
/******************************************************************************************************************************************/

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
        globals.setMaxCoverLiquidationPercent(SET_ADDRESS, 100_0001);

        globals.setMaxCoverLiquidationPercent(SET_ADDRESS, 100_0000);
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

contract SetBootstrapMintTests is BaseMapleGlobalsTest {

    function test_setBootstrapMint_notGovernor() external {
        vm.expectRevert("MG:NOT_GOVERNOR");
        globals.setBootstrapMint(SET_ADDRESS, 1_000e6);

        vm.prank(GOVERNOR);
        globals.setBootstrapMint(SET_ADDRESS, 1_000e6);
    }

    function test_setBootstrapMint() external {
        vm.startPrank(GOVERNOR);

        assertEq(globals.bootstrapMint(SET_ADDRESS), 0);

        globals.setBootstrapMint(SET_ADDRESS, 1_000e6);

        assertEq(globals.bootstrapMint(SET_ADDRESS), 1_000e6);
    }

}

/******************************************************************************************************************************************/
/*** Fee Setters                                                                                                                        ***/
/******************************************************************************************************************************************/

contract SetPlatformManagementFeeRateTests is BaseMapleGlobalsTest {

    address internal PM_ADDRESS = address(new Address());

    function test_setPlatformManagementFeeRate_notGovernor() external {
        vm.expectRevert("MG:NOT_GOVERNOR");
        globals.setPlatformManagementFeeRate(PM_ADDRESS, 20_0000);

        vm.prank(GOVERNOR);
        globals.setPlatformManagementFeeRate(PM_ADDRESS, 20_0000);
    }

    function test_setPlatformManagementFeeRate_outOfBounds() external {
        vm.startPrank(GOVERNOR);

        vm.expectRevert("MG:SPMFR:RATE_GT_100");
        globals.setPlatformManagementFeeRate(PM_ADDRESS, 100_0001);

        globals.setPlatformManagementFeeRate(PM_ADDRESS, 100_0000);
    }

    function test_setPlatformManagementFeeRate() external {
        assertEq(globals.platformManagementFeeRate(PM_ADDRESS), 0);

        vm.prank(GOVERNOR);
        globals.setPlatformManagementFeeRate(PM_ADDRESS, 20_0000);

        assertEq(globals.platformManagementFeeRate(PM_ADDRESS), 20_0000);
    }

}

contract SetPlatformOriginationFeeRateTests is BaseMapleGlobalsTest {

    address internal PM_ADDRESS = address(new Address());

    function test_setPlatformOriginationFeeRate_notGovernor() external {
        vm.expectRevert("MG:NOT_GOVERNOR");
        globals.setPlatformOriginationFeeRate(PM_ADDRESS, 20_0000);

        vm.prank(GOVERNOR);
        globals.setPlatformOriginationFeeRate(PM_ADDRESS, 20_0000);
    }

    function test_setPlatformOriginationFeeRate_outOfBounds() external {
        vm.startPrank(GOVERNOR);

        vm.expectRevert("MG:SPOFR:RATE_GT_100");
        globals.setPlatformOriginationFeeRate(PM_ADDRESS, 100_0001);

        globals.setPlatformOriginationFeeRate(PM_ADDRESS, 100_0000);
    }

    function test_setPlatformOriginationFeeRate() external {
        assertEq(globals.platformOriginationFeeRate(PM_ADDRESS), 0);

        vm.prank(GOVERNOR);
        globals.setPlatformOriginationFeeRate(PM_ADDRESS, 20_0000);

        assertEq(globals.platformOriginationFeeRate(PM_ADDRESS), 20_0000);
    }

}

contract SetPlatformServiceFeeRateTests is BaseMapleGlobalsTest {

    address internal PM_ADDRESS = address(new Address());

    function test_setPlatformServiceFeeRate_notGovernor() external {
        vm.expectRevert("MG:NOT_GOVERNOR");
        globals.setPlatformServiceFeeRate(PM_ADDRESS, 20_0000);

        vm.prank(GOVERNOR);
        globals.setPlatformServiceFeeRate(PM_ADDRESS, 20_0000);
    }

    function test_setPlatformServiceFeeRate_outOfBounds() external {
        vm.startPrank(GOVERNOR);

        vm.expectRevert("MG:SPSFR:RATE_GT_100");
        globals.setPlatformServiceFeeRate(PM_ADDRESS, 100_0001);

        globals.setPlatformServiceFeeRate(PM_ADDRESS, 100_0000);
    }

    function test_setPlatformServiceFeeRate() external {
        assertEq(globals.platformServiceFeeRate(PM_ADDRESS), 0);

        vm.prank(GOVERNOR);
        globals.setPlatformServiceFeeRate(PM_ADDRESS, 20_0000);

        assertEq(globals.platformServiceFeeRate(PM_ADDRESS), 20_0000);
    }

}

/******************************************************************************************************************************************/
/*** Contract Control Functions                                                                                                         ***/
/******************************************************************************************************************************************/

contract SetTimelockWindowTests is BaseMapleGlobalsTest {

    address internal CONTRACT      = address(new Address());
    address internal POOL_DELEGATE = address(new Address());

    bytes32 internal constant FUNCTION_ID_1 = "FUNCTION_ID_1";
    bytes32 internal constant FUNCTION_ID_2 = "FUNCTION_ID_2";

    MockPoolManager internal manager = new MockPoolManager(POOL_DELEGATE);

    function test_setTimelockWindow_notGovernor() external {
        vm.expectRevert("MG:NOT_GOVERNOR");
        globals.setTimelockWindow(CONTRACT, FUNCTION_ID_1, 20 days, 1 days);
    }

    function test_setTimelockWindow() external {
        ( uint128 delay, uint128 duration ) = globals.timelockParametersOf(CONTRACT, FUNCTION_ID_1);

        assertEq(delay,    0);
        assertEq(duration, 0);

        vm.prank(GOVERNOR);
        globals.setTimelockWindow(CONTRACT, FUNCTION_ID_1, 20 days, 1 days);

        ( delay, duration ) = globals.timelockParametersOf(CONTRACT, FUNCTION_ID_1);

        assertEq(delay,    20 days);
        assertEq(duration, 1 days);
    }

    function test_setTimelockWindows_notGovernor() external {
        bytes32[] memory functionIds = new bytes32[](2);

        uint128[] memory delays = new uint128[](2);

        uint128[] memory durations = new uint128[](2);

        vm.expectRevert("MG:NOT_GOVERNOR");
        globals.setTimelockWindows(CONTRACT, functionIds, delays, durations);
    }

    function test_setTimelockWindows() external {
        ( uint128 delay, uint128 duration ) = globals.timelockParametersOf(CONTRACT, FUNCTION_ID_1);

        assertEq(delay,    0);
        assertEq(duration, 0);

        ( delay, duration ) = globals.timelockParametersOf(CONTRACT, FUNCTION_ID_2);

        assertEq(delay,    0);
        assertEq(duration, 0);

        bytes32[] memory functionIds = new bytes32[](2);
        functionIds[0] = FUNCTION_ID_1;
        functionIds[1] = FUNCTION_ID_2;

        uint128[] memory delays = new uint128[](2);
        delays[0] = 10 days;
        delays[1] = 20 days;

        uint128[] memory durations = new uint128[](2);
        durations[0] = 1 days;
        durations[1] = 2 days;

        vm.prank(GOVERNOR);
        globals.setTimelockWindows(CONTRACT, functionIds, delays, durations);

        ( delay, duration ) = globals.timelockParametersOf(CONTRACT, FUNCTION_ID_1);

        assertEq(delay,    10 days);
        assertEq(duration, 1 days);

        ( delay, duration ) = globals.timelockParametersOf(CONTRACT, FUNCTION_ID_2);

        assertEq(delay,    20 days);
        assertEq(duration, 2 days);
    }

}

contract TransferOwnedPoolTests is BaseMapleGlobalsTest {

    address internal POOL_DELEGATE_1 = address(new Address());
    address internal POOL_DELEGATE_2 = address(new Address());

    MockPoolManager internal manager = new MockPoolManager(POOL_DELEGATE_1);

    function setUp() public override {
        super.setUp();
        vm.prank(GOVERNOR);
        globals.activatePoolManager(address(manager));
    }

    function test_transferOwnedPool_notPoolManager() external {
        vm.expectRevert("MG:TOPM:NOT_AUTHORIZED");
        globals.transferOwnedPoolManager(POOL_DELEGATE_1, POOL_DELEGATE_2);
    }

    function test_transferOwnedPool_notPoolDelegate() external {
        vm.prank(address(manager));
        vm.expectRevert("MG:TOPM:NOT_POOL_DELEGATE");
        globals.transferOwnedPoolManager(POOL_DELEGATE_1, POOL_DELEGATE_2);
    }

    function test_transferOwnedPool_alreadyOwns() external {
        vm.prank(GOVERNOR);
        globals.setValidPoolDelegate(POOL_DELEGATE_2, true);

        MockPoolManager manager2 = new MockPoolManager(POOL_DELEGATE_2);

        vm.prank(GOVERNOR);
        globals.activatePoolManager(address(manager2));

        vm.prank(address(manager));
        vm.expectRevert("MG:TOPM:ALREADY_OWNS");
        globals.transferOwnedPoolManager(POOL_DELEGATE_1, POOL_DELEGATE_2);
    }

    function test_transferOwnedPool() external {
        ( address ownedPoolManager1, ) = globals.poolDelegates(POOL_DELEGATE_1);
        ( address ownedPoolManager2, ) = globals.poolDelegates(POOL_DELEGATE_2);

        assertEq(ownedPoolManager1, address(manager));
        assertEq(ownedPoolManager2, address(0));

        vm.prank(GOVERNOR);
        globals.setValidPoolDelegate(POOL_DELEGATE_2, true);

        vm.prank(address(manager));
        globals.transferOwnedPoolManager(POOL_DELEGATE_1, POOL_DELEGATE_2);

        ( ownedPoolManager1, ) = globals.poolDelegates(POOL_DELEGATE_1);
        ( ownedPoolManager2, ) = globals.poolDelegates(POOL_DELEGATE_2);

        assertEq(ownedPoolManager1, address(0));
        assertEq(ownedPoolManager2, address(manager));
    }

}

/******************************************************************************************************************************************/
/*** Schedule Functions                                                                                                                 ***/
/******************************************************************************************************************************************/

contract ScheduleCallTests is BaseMapleGlobalsTest {

    address internal CONTRACT = address(new Address());

    bytes32 internal constant FUNCTION_ID_1 = "FUNCTION_ID_1";

    uint256 internal start;

    function setUp() public override {
        super.setUp();

        vm.prank(GOVERNOR);
        globals.setTimelockWindow(CONTRACT, FUNCTION_ID_1, 20 days, 1 days);

        start = block.timestamp;
    }

    function test_scheduleCall_defaultState() external {
        ( uint256 timestamp, bytes32 dataHash ) = globals.scheduledCalls(address(this), CONTRACT, FUNCTION_ID_1);

        assertEq(timestamp, uint256(0));
        assertEq(dataHash,  bytes32(0));
    }

    function test_scheduleCall() external {
        ( uint256 timestamp, bytes32 dataHash ) = globals.scheduledCalls(address(this), CONTRACT, FUNCTION_ID_1);

        assertEq(timestamp, uint256(0));
        assertEq(dataHash,  bytes32(0));

        globals.scheduleCall(CONTRACT, FUNCTION_ID_1, "some_calldata");

        ( timestamp, dataHash ) = globals.scheduledCalls(address(this), CONTRACT, FUNCTION_ID_1);

        assertEq(timestamp, block.timestamp);
        assertEq(dataHash,  keccak256(abi.encode("some_calldata")));
    }

    function test_scheduleCal_overwrite() external {
        globals.scheduleCall(CONTRACT, FUNCTION_ID_1, "some_calldata");

        vm.warp(start + 1 days);

        ( uint256 timestamp, bytes32 dataHash ) = globals.scheduledCalls(address(this), CONTRACT, FUNCTION_ID_1);

        assertEq(timestamp, start);
        assertEq(dataHash,  keccak256(abi.encode("some_calldata")));

        globals.scheduleCall(CONTRACT, FUNCTION_ID_1, "some more call data");

        ( timestamp, dataHash ) = globals.scheduledCalls(address(this), CONTRACT, FUNCTION_ID_1);

        assertEq(timestamp, start + 1 days);
        assertEq(dataHash,  keccak256(abi.encode("some more call data")));
    }

}

contract IsValidScheduledCallTests is BaseMapleGlobalsTest {

    address internal CONTRACT = address(new Address());

    bytes32 internal constant FUNCTION_ID_1 = "FUNCTION_ID_1";

    function setUp() public override {
        super.setUp();

        vm.prank(GOVERNOR);
        globals.setTimelockWindow(CONTRACT, FUNCTION_ID_1, 20 days, 1 days);
    }

    function test_isValidScheduledCall() external {
        globals.scheduleCall(CONTRACT, FUNCTION_ID_1, "some_calldata");

        vm.warp(block.timestamp + 20 days - 1);

        assertTrue(!globals.isValidScheduledCall(address(this), CONTRACT, FUNCTION_ID_1, "some_calldata"));

        vm.warp(block.timestamp + 1);

        assertTrue(globals.isValidScheduledCall(address(this), CONTRACT, FUNCTION_ID_1, "some_calldata"));

        vm.warp(block.timestamp + 1 days);

        assertTrue(globals.isValidScheduledCall(address(this), CONTRACT, FUNCTION_ID_1, "some_calldata"));

        vm.warp(block.timestamp + 1);

        assertTrue(!globals.isValidScheduledCall(address(this), CONTRACT, FUNCTION_ID_1, "some_calldata"));
    }

}

contract UnScheduleCallTests is BaseMapleGlobalsTest {

    address internal CONTRACT = address(new Address());

    bytes32 internal constant FUNCTION_ID_1 = "FUNCTION_ID_1";

    function setUp() public override {
        super.setUp();

        vm.prank(GOVERNOR);
        globals.setTimelockWindow(CONTRACT, FUNCTION_ID_1, 20 days, 1 days);

        globals.scheduleCall(CONTRACT, FUNCTION_ID_1, "some_calldata");
    }

    function test_unscheduleCall() external {
        ( uint256 timestamp, bytes32 dataHash ) = globals.scheduledCalls(address(this), CONTRACT, FUNCTION_ID_1);

        assertEq(timestamp, block.timestamp);
        assertEq(dataHash,  keccak256(abi.encode("some_calldata")));

        vm.prank(CONTRACT);
        globals.unscheduleCall(address(this), FUNCTION_ID_1, "some_calldata");

        ( timestamp, dataHash ) = globals.scheduledCalls(address(this), CONTRACT, FUNCTION_ID_1);

        assertEq(timestamp, uint256(0));
        assertEq(dataHash,  bytes32(0));
    }

    function test_unscheduleCall_notGovernor() external {
        vm.expectRevert("MG:NOT_GOVERNOR");
        globals.unscheduleCall(address(this), CONTRACT, FUNCTION_ID_1, "some_calldata");
    }

    function test_unscheduleCall_asGovernor() external {
        ( uint256 timestamp, bytes32 dataHash ) = globals.scheduledCalls(address(this), CONTRACT, FUNCTION_ID_1);

        assertEq(timestamp, block.timestamp);
        assertEq(dataHash,  keccak256(abi.encode("some_calldata")));

        vm.prank(GOVERNOR);
        globals.unscheduleCall(address(this), CONTRACT, FUNCTION_ID_1, "some_calldata");

        ( timestamp, dataHash ) = globals.scheduledCalls(address(this), CONTRACT, FUNCTION_ID_1);

        assertEq(timestamp, uint256(0));
        assertEq(dataHash,  bytes32(0));
    }

}

/******************************************************************************************************************************************/
/*** Getter Functions                                                                                                                   ***/
/******************************************************************************************************************************************/

contract GetLatestPriceTests is BaseMapleGlobalsTest {

    address internal ASSET = address(new Address());

    MockChainlinkOracle internal oracle = new MockChainlinkOracle();

    function setUp() public override {
        super.setUp();

        vm.prank(GOVERNOR);
        globals.setPriceOracle(ASSET, address(oracle));
    }

    function test_getLatestPrice_oracleNotSet() external {
        address secondAsset = address(new Address());

        vm.expectRevert("MG:GLP:ZERO_ORACLE");
        globals.getLatestPrice(secondAsset);
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

contract IsFunctionPausedTests is BaseMapleGlobalsTest {

    address internal CONTRACT = address(new Address());

    bytes4 internal SIG = bytes4(0x12345678);

    function test_isFunctionPaused() external {
        vm.startPrank(GOVERNOR);
        globals.setProtocolPause(false);
        globals.setContactPause(CONTRACT, false);
        globals.setFunctionUnpause(CONTRACT, SIG, false);
        vm.stopPrank();

        vm.prank(CONTRACT);
        assertTrue(!globals.isFunctionPaused(SIG));

        vm.startPrank(GOVERNOR);
        globals.setProtocolPause(false);
        globals.setContactPause(CONTRACT, false);
        globals.setFunctionUnpause(CONTRACT, SIG, true);
        vm.stopPrank();

        vm.prank(CONTRACT);
        assertTrue(!globals.isFunctionPaused(SIG));

        vm.startPrank(GOVERNOR);
        globals.setProtocolPause(false);
        globals.setContactPause(CONTRACT, true);
        globals.setFunctionUnpause(CONTRACT, SIG, false);
        vm.stopPrank();

        vm.prank(CONTRACT);
        assertTrue(globals.isFunctionPaused(SIG));

        vm.startPrank(GOVERNOR);
        globals.setProtocolPause(false);
        globals.setContactPause(CONTRACT, true);
        globals.setFunctionUnpause(CONTRACT, SIG, true);
        vm.stopPrank();

        vm.prank(CONTRACT);
        assertTrue(!globals.isFunctionPaused(SIG));

        vm.startPrank(GOVERNOR);
        globals.setProtocolPause(true);
        globals.setContactPause(CONTRACT, false);
        globals.setFunctionUnpause(CONTRACT, SIG, false);
        vm.stopPrank();

        vm.prank(CONTRACT);
        assertTrue(globals.isFunctionPaused(SIG));

        vm.startPrank(GOVERNOR);
        globals.setProtocolPause(true);
        globals.setContactPause(CONTRACT, false);
        globals.setFunctionUnpause(CONTRACT, SIG, true);
        vm.stopPrank();

        vm.prank(CONTRACT);
        assertTrue(!globals.isFunctionPaused(SIG));

        vm.startPrank(GOVERNOR);
        globals.setProtocolPause(true);
        globals.setContactPause(CONTRACT, true);
        globals.setFunctionUnpause(CONTRACT, SIG, false);
        vm.stopPrank();

        vm.prank(CONTRACT);
        assertTrue(globals.isFunctionPaused(SIG));

        vm.startPrank(GOVERNOR);
        globals.setProtocolPause(true);
        globals.setContactPause(CONTRACT, true);
        globals.setFunctionUnpause(CONTRACT, SIG, true);
        vm.stopPrank();

        vm.prank(CONTRACT);
        assertTrue(!globals.isFunctionPaused(SIG));
    }

}
