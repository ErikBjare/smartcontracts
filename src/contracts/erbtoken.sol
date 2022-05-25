// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Token is ERC20 {
    constructor () ERC20("ERBucks", "ERB") {
        _mint(msg.sender, 1337420690 * (10 ** uint256(decimals())));
    }
}
