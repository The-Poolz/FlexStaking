// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Manageable.sol";
import "./ILockedDeal.sol";

contract FlexStaking is Manageable {
    event InvestInfo(
        uint256 Id,
        uint256 LockedAmount,
        uint256 Earn,
        uint256 Duration
    );
    event CreatedPool(
        uint256 Id,
        address LockedToken,
        address RewardToken,
        uint256 TokensAmount,
        uint256 StartTime,
        uint256 FinishTime,
        uint256 APR,
        uint256 MinDuration,
        uint256 MaxDuration,
        uint256 MinAmount,
        uint256 MaxAmount,
        uint256 EarlyWithdraw
    );

    function CreateStakingPool(
        address lockedToken, // The token address that is locking
        address rewardToken, // The reward token address
        uint256 tokensAmount, // Total amount of reward tokens
        uint256 startTime, // The time that can start using the staking (all time is Unix, sec)
        uint256 finishTime, // The time that no longer can use the staking
        uint256 APR, // Annual percentage rate
        uint256 minDuration, // For how long the user can set up the staking
        uint256 maxDuration,
        uint256 minAmount, // How much user can stake
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
            APR > 0 && minDuration > 0 && minAmount > 0 && tokensAmount > 0,
            "the value should be greater than zero!"
        );
        require(
            startTime >= block.timestamp - 60 && finishTime > startTime,
            "invalid start time!"
        );
        require(maxAmount >= minAmount, "invalid maxium amount!");
        require(
            maxDuration <= finishTime - startTime && maxDuration >= minDuration,
            "invalid maximum duration time!"
        );
        PoolsMap[++TotalPools] = Pool(
            lockedToken,
            rewardToken,
            tokensAmount,
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
            tokensAmount
        );
        Reserves[TotalPools] = tokensAmount;
        emit CreatedPool(
            TotalPools,
            lockedToken,
            rewardToken,
            tokensAmount,
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
        uint256 duration // in seconds
    ) public whenNotPaused notNullAddress(LockedDealAddress) {
        require(id > 0 && id <= TotalPools, "wrong id!");
        require(
            amount >= PoolsMap[id].MinAmount &&
                amount <= PoolsMap[id].MaxAmount,
            "wrong amount!"
        );
        require(
            duration <= PoolsMap[id].MaxDuration &&
                duration >= PoolsMap[id].MinDuration,
            "wrong duration time!"
        );
        uint256 earn = ((amount * PoolsMap[id].APR) / 365 / 24 / 60 / 60) *
            duration;
        require(Reserves[id] >= earn, "not enough tokens!");
        uint256 lockedAmount = amount;
        address rewardToken = PoolsMap[id].RewardToken;
        address lockedToken = PoolsMap[id].LockedToken;
        uint256 earlyWithdraw = PoolsMap[id].EarlyWithdraw;
        TransferInToken(lockedToken, msg.sender, amount);
        if (rewardToken != lockedToken && earn > 0) {
            LockToken(rewardToken, earn, duration, earlyWithdraw);
        } else {
            lockedAmount += earn;
        }
        LockToken(lockedToken, lockedAmount, duration, earlyWithdraw);
        Reserves[id] -= earn;
        emit InvestInfo(id, amount, earn, duration);
    }

    function LockToken(
        address token,
        uint256 amount,
        uint256 duration,
        uint256 earlyWithdraw
    ) internal {
        ApproveAllowanceERC20(token, LockedDealAddress, amount);
        ILockedDeal(LockedDealAddress).CreateNewPool(
            token,
            block.timestamp + duration - earlyWithdraw,
            block.timestamp + duration,
            amount,
            msg.sender
        );
    }
}
