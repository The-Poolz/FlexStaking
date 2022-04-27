// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "poolz-helper-v2/contracts/ERC20Helper.sol";
import "poolz-helper-v2/contracts/ETHHelper.sol";
import "poolz-helper-v2/contracts/GovManager.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Manageable is GovManager, ETHHelper, ERC20Helper, Pausable {
    modifier greaterThanZero(uint256 n) {
        require(n > 0, "The value should be greater than zero!");
        _;
    }

    constructor() {}

    address public LockedDealAddress;

    //mapping(address => uint256) FeeMap;
    //uint256 public Fee;

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
