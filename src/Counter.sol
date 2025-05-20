// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {BLSSigCheckOperatorStateRetriever} from
    "lib/eigenlayer-middleware/src/unaudited/BLSSigCheckOperatorStateRetriever.sol";
import {BLSSignatureChecker} from "lib/eigenlayer-middleware/src/BLSSignatureChecker.sol";
import {ISlashingRegistryCoordinator} from "lib/eigenlayer-middleware/src/interfaces/ISlashingRegistryCoordinator.sol";

contract Counter is BLSSigCheckOperatorStateRetriever, BLSSignatureChecker {
    /// @title Counter
    /// @notice A simple counter contract that implements BLS signature checking
    /// @dev Inherits from BLSSigCheckOperatorStateRetriever and BLSSignatureChecker
    /// @param _registryCoordinator The address of the registry coordinator contract

    /// @notice The current number
    uint256 public number;
    /// @notice The block number stale measure
    uint32 public BLOCK_STALE_MEASURE = 300;
    /// @notice The quorum threshold
    uint256 public QUORUM_THRESHOLD = 66; // 66% of the quorum
    /// @notice The threshold denominator
    uint256 public THRESHOLD_DENOMINATOR = 100;

    /// @notice The error for future block number
    error FutureBlockNumber();
    /// @notice The error for stale block number
    error StaleBlockNumber();
    /// @notice The error for invalid hash
    error InvalidHash();
    /// @notice The error for insufficient quorum threshold
    error InsufficientQuorumThreshold();

    constructor(ISlashingRegistryCoordinator _registryCoordinator) BLSSignatureChecker(_registryCoordinator) {}

    function increment(
        bytes32 msgHash,
        bytes calldata quorumNumbers,
        uint32 referenceBlockNumber,
        NonSignerStakesAndSignature memory params
    ) public {
        require(referenceBlockNumber < block.number, FutureBlockNumber());
        require((referenceBlockNumber + BLOCK_STALE_MEASURE) >= uint32(block.number), StaleBlockNumber());

        bytes32 expectedHash = sha256(abi.encode(number));
        require(msgHash == expectedHash, InvalidHash());
         (QuorumStakeTotals memory stakeTotals,) =
        checkSignatures(msgHash, quorumNumbers, referenceBlockNumber, params);

        // Check that signatories own at least 66% of each quorum
        for (uint256 i = 0; i < quorumNumbers.length; i++) {
            require(
                stakeTotals.signedStakeForQuorum[i] * THRESHOLD_DENOMINATOR
                    >= stakeTotals.totalStakeForQuorum[i] * QUORUM_THRESHOLD,
                InsufficientQuorumThreshold()
            );
        }

        number++;
    }
}
