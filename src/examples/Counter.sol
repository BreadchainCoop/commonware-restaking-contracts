// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {BLSSignatureChecker} from "lib/eigenlayer-middleware/src/BLSSignatureChecker.sol";
import {ISlashingRegistryCoordinator} from "lib/eigenlayer-middleware/src/interfaces/ISlashingRegistryCoordinator.sol";

import {IAvsServiceManager} from "../interfaces/IAvsServiceManager.sol";

/// @title Counter
/// @notice A simple counter contract that implements BLS signature checking.
///         Quorum threshold and block staleness parameters are read from the
///         AVS service manager wrapper at runtime rather than hardcoded.
contract Counter is BLSSignatureChecker {
    /// @notice The current number
    uint256 public number;

    /// @notice The AVS service manager contract that provides quorum and staleness parameters
    IAvsServiceManager public immutable AVS_SERVICE_MANAGER;

    /// @notice Thrown when referenceBlockNumber is >= current block
    error FutureBlockNumber();
    /// @notice Thrown when referenceBlockNumber is older than BLOCK_STALE_MEASURE blocks ago
    error StaleBlockNumber();
    /// @notice Thrown when the reconstructed hash does not match msgHash
    error InvalidHash();
    /// @notice Thrown when signatories hold less than the quorum threshold of stake
    error InsufficientQuorumThreshold();

    /// @param _registryCoordinator The registry coordinator contract
    /// @param _avsServiceManager The AVS service manager wrapper providing threshold constants
    constructor(ISlashingRegistryCoordinator _registryCoordinator, IAvsServiceManager _avsServiceManager)
        BLSSignatureChecker(_registryCoordinator)
    {
        AVS_SERVICE_MANAGER = _avsServiceManager;
    }

    function increment(
        bytes32 msgHash,
        bytes calldata quorumNumbers,
        uint32 referenceBlockNumber,
        NonSignerStakesAndSignature memory params
    ) public {
        require(referenceBlockNumber < block.number, FutureBlockNumber());
        require(
            uint256(referenceBlockNumber) + AVS_SERVICE_MANAGER.BLOCK_STALE_MEASURE() >= block.number,
            StaleBlockNumber()
        );

        bytes32 expectedHash = sha256(abi.encode(number));
        require(msgHash == expectedHash, InvalidHash());

        (QuorumStakeTotals memory stakeTotals,) = checkSignatures(msgHash, quorumNumbers, referenceBlockNumber, params);

        uint256 quorumThreshold = AVS_SERVICE_MANAGER.QUORUM_THRESHOLD();
        uint256 thresholdDenominator = AVS_SERVICE_MANAGER.THRESHOLD_DENOMINATOR();
        for (uint256 i = 0; i < quorumNumbers.length; i++) {
            require(
                stakeTotals.signedStakeForQuorum[i] * thresholdDenominator
                    >= stakeTotals.totalStakeForQuorum[i] * quorumThreshold,
                InsufficientQuorumThreshold()
            );
        }
        number++;
    }
}
