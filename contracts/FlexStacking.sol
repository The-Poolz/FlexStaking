// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Manageable.sol";
import "./ILockedDeal.sol";

contract FlexStacking is Manageable {
    event InvestInfo(
        uint256 id,
        uint256 lockedAmount,
        uint256 earn,
        uint256 duration
    );
    event CretedPool(
        address LockedToken,
        uint256 LockedAmount,
        address RewardToken,
        uint256 RewardAmount,
        uint256 StartTime,
        uint256 FinishTime,
        uint256 APR,
        uint256 MinDuration,
        uint256 MaxDuration,
        uint256 minAmount,
        uint256 maxAmount,
        uint256 earlyWithdraw
    );

    mapping(uint256 => Pool) PoolsMap;
    uint256 TotalPools;

    struct Pool {
        address LockedToken;
        uint256 LockedAmount;
        address RewardToken;
        uint256 RewardAmount;
        uint256 StartTime;
        uint256 FinishTime;
        uint256 APR;
        uint256 MinDuration;
        uint256 MaxDuration;
        uint256 minAmount;
        uint256 maxAmount;
        uint256 earlyWithdraw;
    }

    function CreateStakingPool(
        address lockedToken,
        uint256 lockedAmount,
        address rewardToken,
        uint256 rewardAmount,
        uint256 startTime,
        uint256 finishTime,
        uint256 APR,
        uint256 minDuration,
        uint256 maxDuration,
        uint256 minAmount,
        uint256 maxAmount,
        uint256 earlyWithdraw
    )
        public
        onlyOwnerOrGov
        whenNotPaused
        greaterThanZero(lockedAmount)
    // "Stack Too Deep" error when using modifier
    // greaterThanZero(startTime)
    // greaterThanZero(finishTime)
    // greaterThanZero(maxDuration)
    // greaterThanZero(maxAmount)
    // greaterThanZero(APR)
    {
        require(
            APR > 0 && startTime > 0 && finishTime > 0 && maxDuration > 0 && maxAmount > 0,
            "The value should be greater than zero!"
        );
        require(
            LockedDealAddress != address(0),
            "Invalid Locked Deal address!"
        );
        require(lockedToken != address(0), "Invalid token address!");
        require(
            maxDuration <= finishTime - startTime, 
            "Invalid maximum duration time!" 
        );
        PoolsMap[++TotalPools] = Pool(
            lockedToken,
            lockedAmount,
            rewardToken,
            rewardAmount,
            startTime,
            finishTime,
            APR,
            minDuration,
            maxDuration,
            minAmount,
            maxAmount,
            earlyWithdraw
        );
        if (lockedToken != rewardToken) {
            TransferInToken(
                PoolsMap[TotalPools].RewardToken,
                msg.sender,
                rewardAmount
            );
        } else {
            lockedAmount += rewardAmount;
        }
        TransferInToken(
            PoolsMap[TotalPools].LockedToken,
            msg.sender,
            lockedAmount
        );
        emit CretedPool(
            lockedToken,
            lockedAmount,
            rewardToken,
            rewardAmount,
            startTime,
            finishTime,
            APR,
            minDuration,
            maxDuration,
            minAmount,
            maxAmount,
            earlyWithdraw
        );
    }

    function Stake(
        uint256 id,
        uint256 amount,
        uint256 duration
    ) public whenNotPaused {
        require(id <= TotalPools && id > 0, "wrong id!");
        require(
            duration < PoolsMap[id].MaxDuration &&
                duration > PoolsMap[id].MinDuration,
            "Duration error!"
        );
        uint256 earn = ((amount * PoolsMap[id].APR) / 365 / 24 / 60 / 60) *
            duration;
        uint256 lockedAmount = amount;
        if (PoolsMap[id].RewardToken != PoolsMap[id].LockedToken) {
            ILockedDeal(LockedDealAddress).CreateNewPool(
                PoolsMap[id].RewardToken,
                block.timestamp + duration - PoolsMap[id].earlyWithdraw, // The global variable 'now' is deprecated, 'block.timestamp' should be used instead
                block.timestamp + duration,// https://docs.soliditylang.org/en/v0.8.13/070-breaking-changes.html?highlight=block.timestamp#how-to-update-your-code
                earn,
                msg.sender
            );
        } else {
            lockedAmount += earn;
        }
        ILockedDeal(LockedDealAddress).CreateNewPool(
            PoolsMap[id].LockedToken,
            block.timestamp + duration - PoolsMap[id].earlyWithdraw,
            block.timestamp + duration,
            lockedAmount,
            msg.sender
        );
        emit InvestInfo(id, amount, earn, duration);
    }
}
