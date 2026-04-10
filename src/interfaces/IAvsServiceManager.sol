// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

/// @title IAvsServiceManager
/// @notice Interface exposing quorum threshold and block staleness constants for AVS service managers
/// @dev Implemented by AvsServiceManagerWrapper; read by consumer contracts at runtime
interface IAvsServiceManager {
    /// @notice Numerator used when computing the quorum threshold
    function QUORUM_THRESHOLD() external view returns (uint256);

    /// @notice Denominator used when computing the quorum threshold (representing the full operator count)
    function THRESHOLD_DENOMINATOR() external view returns (uint256);

    /// @notice Maximum number of blocks a reference block may lag behind the current block
    function BLOCK_STALE_MEASURE() external view returns (uint256);
}
