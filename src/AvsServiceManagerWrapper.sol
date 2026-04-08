// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {IServiceManager} from "lib/eigenlayer-middleware/src/interfaces/IServiceManager.sol";

import {IAvsServiceManager} from "./interfaces/IAvsServiceManager.sol";

/// @title AvsServiceManagerWrapper
/// @notice Wraps a deployed ServiceManager and exposes configurable quorum threshold
///         and block staleness constants readable by AVS consumer contracts at runtime
/// @dev All calls other than the three constants are forwarded to the underlying
///      SERVICE_MANAGER via `call`. Note that msg.sender is NOT preserved —
///      authorization-gated write functions should be called directly on the
///      underlying SERVICE_MANAGER address.
contract AvsServiceManagerWrapper is IAvsServiceManager {
    /// @notice Numerator used when computing the quorum threshold
    uint256 public immutable QUORUM_THRESHOLD;

    /// @notice Denominator used when computing the quorum threshold (representing the full operator count)
    uint256 public immutable THRESHOLD_DENOMINATOR;

    /// @notice Maximum number of blocks a reference block may lag behind the current block
    uint256 public immutable BLOCK_STALE_MEASURE;

    /// @notice The underlying ServiceManager this contract wraps
    IServiceManager public immutable SERVICE_MANAGER;

    /// @param _serviceManager The address of the deployed ServiceManager to wrap
    /// @param _quorumThreshold Numerator of the quorum threshold fraction
    /// @param _thresholdDenominator Denominator of the quorum threshold fraction
    /// @param _blockStaleMeasure Maximum age in blocks for a valid reference block
    constructor(
        address _serviceManager,
        uint256 _quorumThreshold,
        uint256 _thresholdDenominator,
        uint256 _blockStaleMeasure
    ) {
        require(_serviceManager != address(0), "zero address");
        require(_thresholdDenominator > 0, "zero denominator");
        require(_quorumThreshold <= _thresholdDenominator, "threshold exceeds denominator");
        SERVICE_MANAGER = IServiceManager(_serviceManager);
        QUORUM_THRESHOLD = _quorumThreshold;
        THRESHOLD_DENOMINATOR = _thresholdDenominator;
        BLOCK_STALE_MEASURE = _blockStaleMeasure;
    }

    /// @notice Forward any unrecognized call to the underlying SERVICE_MANAGER
    /// @dev Uses `call` so msg.sender is the wrapper, not the original caller
    fallback() external payable {
        address target = address(SERVICE_MANAGER);
        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := call(gas(), target, callvalue(), 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())
            switch result
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }

    receive() external payable {}
}
