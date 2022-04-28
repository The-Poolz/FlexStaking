// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Manageable.sol";
import "./ILockedDeal.sol";

contract FlexStaking is Manageable {
    event InvestInfo(
        uint256 id,
        uint256 lockedAmount,
        uint256 earn,
        uint256 duration
    );
    event CretedPool(
        uint256 Id,
        address LockedToken,
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

    function CreateStakingPool(
        address lockedToken,
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
        notNullAddress(lockedToken)
        notNullAddress(rewardToken)
    {
        require(
            APR > 0 &&
                startTime > 0 &&
                finishTime > 0 &&
                maxDuration > 0 &&
                maxAmount > 0 &&
                rewardAmount > 0,
            "The value should be greater than zero!"
        );
        require(
            maxDuration <= finishTime - startTime,
            "Invalid maximum duration time!"
        );
        PoolsMap[++TotalPools] = Pool(
            lockedToken,
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
        TransferInToken(
            PoolsMap[TotalPools].RewardToken,
            msg.sender,
            rewardAmount
        );
        Reserves[TotalPools] = rewardAmount;
        emit CretedPool(
            TotalPools,
            lockedToken,
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
    ) public whenNotPaused notNullAddress(LockedDealAddress) {
        require(id <= TotalPools && id > 0, "wrong id!");
        require(amount <= PoolsMap[id].MaxAmount && amount > 0, "wrong amount");
        require(
            duration <= PoolsMap[id].MaxDuration &&
                duration >= PoolsMap[id].MinDuration,
            "wrong duration time!"
        );
        uint256 earn = ((amount * PoolsMap[id].APR) / 365 / 24 / 60 / 60) *
            duration;
        require(Reserves[id] >= earn, "not enough tokens!");
        uint256 lockedAmount = amount;
        if (PoolsMap[id].RewardToken != PoolsMap[id].LockedToken) {
            ApproveAllowanceERC20(
                PoolsMap[id].RewardToken,
                LockedDealAddress,
                lockedAmount
            );
            ILockedDeal(LockedDealAddress).CreateNewPool(
                PoolsMap[id].RewardToken,
                block.timestamp + duration - PoolsMap[id].EarlyWithdraw,
                block.timestamp + duration,
                earn,
                msg.sender
            );
        } else {
            lockedAmount += earn;
        }
        ApproveAllowanceERC20(
            PoolsMap[id].LockedToken,
            LockedDealAddress,
            lockedAmount
        );
        ILockedDeal(LockedDealAddress).CreateNewPool(
            PoolsMap[id].LockedToken,
            block.timestamp + duration - PoolsMap[id].EarlyWithdraw,
            block.timestamp + duration,
            lockedAmount,
            msg.sender
        );
        Reserves[id] -= earn;
        emit InvestInfo(id, amount, earn, duration);
    }
}
