// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Locked Deal V2 Interface
// Need to update Interface in poolz-helper-v2
interface ILockedDeal {
    function CreateNewPool(
        address _Token,
        uint256 _StartTime,
        uint256 _FinishTime,
        uint256 _StartAmount,
        address _Owner
    ) external returns (uint256);

    function WithdrawToken(uint256 _PoolId) external returns (bool);
}
