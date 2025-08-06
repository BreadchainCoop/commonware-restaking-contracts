// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Counter} from "../src/Counter.sol";
import {ISlashingRegistryCoordinator} from "lib/eigenlayer-middleware/src/interfaces/ISlashingRegistryCoordinator.sol";
import {BLSMockAVSDeployer} from "lib/eigenlayer-middleware/test/utils/BLSMockAVSDeployer.sol";
import {BitmapUtils} from "lib/eigenlayer-middleware/src/libraries/BitmapUtils.sol";
import {BN254} from "lib/eigenlayer-middleware/src/libraries/BN254.sol";
import {IBLSSignatureCheckerTypes, IBLSSignatureCheckerErrors} from "lib/eigenlayer-middleware/src/interfaces/IBLSSignatureChecker.sol";

contract CounterTest is BLSMockAVSDeployer {
    using BN254 for BN254.G1Point;

    Counter public counter;

    function setUp() public virtual {
        _setUpBLSMockAVSDeployer();
        counter = new Counter(registryCoordinator);
    }

    function test_InitialState() public {
        assertEq(counter.number(), 0, "Counter should start at 0");
        assertEq(counter.BLOCK_STALE_MEASURE(), 300, "BLOCK_STALE_MEASURE should be 300");
        assertEq(counter.QUORUM_THRESHOLD(), 66, "QUORUM_THRESHOLD should be 66");
        assertEq(counter.THRESHOLD_DENOMINATOR(), 100, "THRESHOLD_DENOMINATOR should be 100");
    }

    function test_Increment_FutureBlockNumber() public {
        uint256 numNonSigners = 1;
        uint256 quorumBitmap = 1;
        bytes memory quorumNumbers = BitmapUtils.bitmapToBytesArray(quorumBitmap);

        (
            uint32 referenceBlockNumber,
            IBLSSignatureCheckerTypes.NonSignerStakesAndSignature memory nonSignerStakesAndSignature
        ) = _registerSignatoriesAndGetNonSignerStakeAndSignatureRandom(123, numNonSigners, quorumBitmap);

        // Use a future block number
        uint32 futureBlockNumber = uint32(block.number + 1);

        vm.expectRevert(Counter.FutureBlockNumber.selector);
        counter.increment(msgHash, quorumNumbers, futureBlockNumber, nonSignerStakesAndSignature);
    }

    function test_Increment_InvalidHash() public {
        uint256 numNonSigners = 1;
        uint256 quorumBitmap = 1;
        bytes memory quorumNumbers = BitmapUtils.bitmapToBytesArray(quorumBitmap);

        (
            uint32 referenceBlockNumber,
            IBLSSignatureCheckerTypes.NonSignerStakesAndSignature memory nonSignerStakesAndSignature
        ) = _registerSignatoriesAndGetNonSignerStakeAndSignatureRandom(123, numNonSigners, quorumBitmap);

        // Use an invalid message hash (not the expected hash for counter.number())
        bytes32 invalidHash = keccak256(abi.encodePacked("invalid hash"));

        vm.expectRevert(Counter.InvalidHash.selector);
        counter.increment(invalidHash, quorumNumbers, referenceBlockNumber, nonSignerStakesAndSignature);
    }

    function test_Increment_ValidHash() public {
        uint256 numNonSigners = 1;
        uint256 quorumBitmap = 1;
        bytes memory quorumNumbers = BitmapUtils.bitmapToBytesArray(quorumBitmap);

        (
            uint32 referenceBlockNumber,
            IBLSSignatureCheckerTypes.NonSignerStakesAndSignature memory nonSignerStakesAndSignature
        ) = _registerSignatoriesAndGetNonSignerStakeAndSignatureRandom(123, numNonSigners, quorumBitmap);

        // Use the correct hash for the current counter value (0)
        bytes32 correctHash = sha256(abi.encode(counter.number()));

        // This should pass the hash validation but fail at BLS signature verification
        // which is expected since the BLS signature is generated for a different message
        vm.expectRevert(IBLSSignatureCheckerErrors.InvalidBLSSignature.selector);
        counter.increment(correctHash, quorumNumbers, referenceBlockNumber, nonSignerStakesAndSignature);
    }

    function test_Increment_WithMultipleQuorums() public {
        uint256 numNonSigners = 1;
        uint256 quorumBitmap = 3; // Two quorums: 0 and 1
        bytes memory quorumNumbers = BitmapUtils.bitmapToBytesArray(quorumBitmap);

        (
            uint32 referenceBlockNumber,
            IBLSSignatureCheckerTypes.NonSignerStakesAndSignature memory nonSignerStakesAndSignature
        ) = _registerSignatoriesAndGetNonSignerStakeAndSignatureRandom(123, numNonSigners, quorumBitmap);

        bytes32 correctHash = sha256(abi.encode(counter.number()));

        // This should pass the hash validation but fail at BLS signature verification
        vm.expectRevert(IBLSSignatureCheckerErrors.InvalidBLSSignature.selector);
        counter.increment(correctHash, quorumNumbers, referenceBlockNumber, nonSignerStakesAndSignature);
    }

    function test_Increment_WithNoNonSigners() public {
        uint256 numNonSigners = 0;
        uint256 quorumBitmap = 1;
        bytes memory quorumNumbers = BitmapUtils.bitmapToBytesArray(quorumBitmap);

        (
            uint32 referenceBlockNumber,
            IBLSSignatureCheckerTypes.NonSignerStakesAndSignature memory nonSignerStakesAndSignature
        ) = _registerSignatoriesAndGetNonSignerStakeAndSignatureRandom(123, numNonSigners, quorumBitmap);

        bytes32 correctHash = sha256(abi.encode(counter.number()));

        // This should pass the hash validation but fail at BLS signature verification
        vm.expectRevert(IBLSSignatureCheckerErrors.InvalidBLSSignature.selector);
        counter.increment(correctHash, quorumNumbers, referenceBlockNumber, nonSignerStakesAndSignature);
    }

    function test_Increment_WithMultipleNonSigners() public {
        uint256 numNonSigners = 3;
        uint256 quorumBitmap = 1;
        bytes memory quorumNumbers = BitmapUtils.bitmapToBytesArray(quorumBitmap);

        (
            uint32 referenceBlockNumber,
            IBLSSignatureCheckerTypes.NonSignerStakesAndSignature memory nonSignerStakesAndSignature
        ) = _registerSignatoriesAndGetNonSignerStakeAndSignatureRandom(123, numNonSigners, quorumBitmap);

        bytes32 correctHash = sha256(abi.encode(counter.number()));

        // This should pass the hash validation but fail at BLS signature verification
        vm.expectRevert(IBLSSignatureCheckerErrors.InvalidBLSSignature.selector);
        counter.increment(correctHash, quorumNumbers, referenceBlockNumber, nonSignerStakesAndSignature);
    }

    function test_BlockNumberValidation() public {
        uint256 numNonSigners = 1;
        uint256 quorumBitmap = 1;
        bytes memory quorumNumbers = BitmapUtils.bitmapToBytesArray(quorumBitmap);

        (
            uint32 referenceBlockNumber,
            IBLSSignatureCheckerTypes.NonSignerStakesAndSignature memory nonSignerStakesAndSignature
        ) = _registerSignatoriesAndGetNonSignerStakeAndSignatureRandom(123, numNonSigners, quorumBitmap);

        // Test with current block number (should pass hash validation but fail BLS verification)
        bytes32 correctHash = sha256(abi.encode(counter.number()));
        vm.expectRevert(IBLSSignatureCheckerErrors.InvalidBLSSignature.selector);
        counter.increment(correctHash, quorumNumbers, referenceBlockNumber, nonSignerStakesAndSignature);
    }
}
