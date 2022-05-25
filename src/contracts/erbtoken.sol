// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.6.0/contracts/token/ERC20/ERC20.sol";

contract Token is ERC20 {
    constructor () ERC20("ERBucks", "ERB") {
        _mint(msg.sender, 1337420690 * (10 ** uint256(decimals())));
    }
}
