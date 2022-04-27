// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// Need to rename the 'Token' to 'ERC20Token' in poolz-helper-v2 to fix integration errors
contract ERC20Token is ERC20, Ownable {
    constructor(string memory _TokenName, string memory _TokenSymbol)
        ERC20(_TokenName, _TokenSymbol)
    {
        _mint(msg.sender, 5000000000000);
    }

    function FreeTest() public {
        _mint(msg.sender, 5000000);
    }
}
