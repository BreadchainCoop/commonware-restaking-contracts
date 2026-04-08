// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";

import {AvsServiceManagerWrapper} from "../src/AvsServiceManagerWrapper.sol";
import {IAvsServiceManager} from "../src/interfaces/IAvsServiceManager.sol";

/// @dev Minimal contract used to verify fallback call forwarding
contract MockServiceManager {
    uint256 public value;

    function setValue(uint256 _value) external {
        value = _value;
    }

    function getValue() external view returns (uint256) {
        return value;
    }
}

contract AvsServiceManagerWrapperTest is Test {
    MockServiceManager public mock;
    AvsServiceManagerWrapper public wrapper;

    uint256 constant QUORUM_THRESHOLD = 2;
    uint256 constant THRESHOLD_DENOMINATOR = 3;
    uint256 constant BLOCK_STALE_MEASURE = 300;

    function setUp() public {
        mock = new MockServiceManager();
        wrapper =
            new AvsServiceManagerWrapper(address(mock), QUORUM_THRESHOLD, THRESHOLD_DENOMINATOR, BLOCK_STALE_MEASURE);
    }

    // =========================================================================
    // Constructor validation
    // =========================================================================

    function test_Constructor_ZeroAddressReverts() public {
        vm.expectRevert("zero address");
        new AvsServiceManagerWrapper(address(0), QUORUM_THRESHOLD, THRESHOLD_DENOMINATOR, BLOCK_STALE_MEASURE);
    }

    function test_Constructor_ZeroDenominatorReverts() public {
        vm.expectRevert("zero denominator");
        new AvsServiceManagerWrapper(address(mock), QUORUM_THRESHOLD, 0, BLOCK_STALE_MEASURE);
    }

    function test_Constructor_ThresholdExceedsDenominatorReverts() public {
        vm.expectRevert("threshold exceeds denominator");
        new AvsServiceManagerWrapper(address(mock), 4, 3, BLOCK_STALE_MEASURE);
    }

    function test_Constructor_ThresholdEqualsDenominatorSucceeds() public {
        AvsServiceManagerWrapper w = new AvsServiceManagerWrapper(address(mock), 3, 3, BLOCK_STALE_MEASURE);
        assertEq(w.QUORUM_THRESHOLD(), 3);
        assertEq(w.THRESHOLD_DENOMINATOR(), 3);
    }

    // =========================================================================
    // Immutable state
    // =========================================================================

    function test_Immutables_SetCorrectly() public view {
        assertEq(wrapper.QUORUM_THRESHOLD(), QUORUM_THRESHOLD);
        assertEq(wrapper.THRESHOLD_DENOMINATOR(), THRESHOLD_DENOMINATOR);
        assertEq(wrapper.BLOCK_STALE_MEASURE(), BLOCK_STALE_MEASURE);
        assertEq(address(wrapper.SERVICE_MANAGER()), address(mock));
    }

    function test_ImplementsIAvsServiceManager() public view {
        IAvsServiceManager iface = IAvsServiceManager(address(wrapper));
        assertEq(iface.QUORUM_THRESHOLD(), QUORUM_THRESHOLD);
        assertEq(iface.THRESHOLD_DENOMINATOR(), THRESHOLD_DENOMINATOR);
        assertEq(iface.BLOCK_STALE_MEASURE(), BLOCK_STALE_MEASURE);
    }

    // =========================================================================
    // Fallback forwarding
    // =========================================================================

    function test_Fallback_ForwardsWriteCall() public {
        MockServiceManager(address(wrapper)).setValue(42);
        assertEq(mock.value(), 42);
    }

    function test_Fallback_ForwardsReadCall() public {
        mock.setValue(99);
        uint256 result = MockServiceManager(address(wrapper)).getValue();
        assertEq(result, 99);
    }

    function test_Fallback_RevertsOnUnderlyingRevert() public {
        // Deploy a target that always reverts
        RevertingTarget reverting = new RevertingTarget();
        AvsServiceManagerWrapper w = new AvsServiceManagerWrapper(address(reverting), 1, 1, 1);

        vm.expectRevert("always reverts");
        RevertingTarget(address(w)).fail();
    }

    // =========================================================================
    // receive()
    // =========================================================================

    function test_Receive_AcceptsEth() public {
        vm.deal(address(this), 1 ether);
        (bool ok,) = address(wrapper).call{value: 1 ether}("");
        assertTrue(ok);
        assertEq(address(wrapper).balance, 1 ether);
    }
}

contract RevertingTarget {
    function fail() external pure {
        revert("always reverts");
    }
}
