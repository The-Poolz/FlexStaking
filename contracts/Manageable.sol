// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "poolz-helper-v2/contracts/ERC20Helper.sol";
import "poolz-helper-v2/contracts/ETHHelper.sol";
import "poolz-helper-v2/contracts/GovManager.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Manageable is GovManager, ETHHelper, ERC20Helper, Pausable {
    event WithdrawnLeftover(uint256 amount, address receiver);

    modifier notNullAddress(address _contract) {
        require(_contract != address(0), "Invalid contract address!");
        _;
    }

    constructor() {}

    mapping(uint256 => Pool) public PoolsMap;
    mapping(uint256 => uint256) public Reserves; // Reserve of tokens
    uint256 TotalPools;
    address public LockedDealAddress;

    struct Pool {
        address LockedToken; // The token address that is locking
        address RewardToken; // The reward token address
        uint256 TokensAmount; // Total amount of reward tokens
        uint256 StartTime; // The time that can start using the staking
        uint256 FinishTime; // The time that no longer can use the staking
        uint256 APR; // Annual percentage rate
        uint256 MinDuration; // For how long the user can set up the staking
        uint256 MaxDuration;
        uint256 MinAmount; // How much user can stake
        uint256 MaxAmount;
        uint256 EarlyWithdraw;
    }

    function WithdrawLeftOver(uint256 id) public onlyOwnerOrGov {
        require(id > 0 && id <= TotalPools, "wrong id!");
        require(
            block.timestamp > PoolsMap[id].FinishTime,
            "should wait when pool is over!"
        );
        require(Reserves[id] > 0, "all tokens distributed!");
        TransferToken(PoolsMap[id].RewardToken, msg.sender, Reserves[id]);
        emit WithdrawnLeftover(Reserves[id], msg.sender);
        Reserves[id] = 0;
    }

    function SetLockedDealAddress(address lockedDeal) public onlyOwnerOrGov {
        require(
            LockedDealAddress != lockedDeal,
            "the address of the Locked Deal has already been changed!"
        );
        LockedDealAddress = lockedDeal;
    }

    function Pause() public onlyOwnerOrGov {
        _pause();
    }

    function Unpause() public onlyOwnerOrGov {
        _unpause();
    }
}
