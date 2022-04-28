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
    mapping(uint256 => uint256) public Reserves;
    uint256 TotalPools;
    address public LockedDealAddress;

    struct Pool {
        address LockedToken;
        address RewardToken;
        uint256 RewardAmount;
        uint256 StartTime;
        uint256 FinishTime;
        uint256 APR; // Annual percentage rate
        uint256 MinDuration;
        uint256 MaxDuration;
        uint256 MinAmount;
        uint256 MaxAmount;
        uint256 EarlyWithdraw;
    }

    function WithdrawLeftOver(uint256 id) public onlyOwnerOrGov {
        require(id < TotalPools, "Wrong id!");
        require(
            block.timestamp > PoolsMap[id].FinishTime,
            "You should wait when pool is over"
        );
        TransferToken(PoolsMap[id].RewardToken, msg.sender, Reserves[id]);
        emit WithdrawnLeftover(Reserves[id], msg.sender);
        Reserves[id] = 0;
    }

    function SetLockedDealAddress(address lockedDeal) public onlyOwnerOrGov {
        require(
            LockedDealAddress != lockedDeal,
            "The address of the Locked Deal has already been changed!"
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
