// SPDX-License-Identifier: LGPL-3.0-only

pragma solidity 0.8.24;

import "../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract StakingToken is ERC20 {
    // === Constructor ===
    constructor(string memory name_, string memory symbol_) ERC20(name_, symbol_) {}

    // === External functions ===
    function mint(uint256 amount_) external {
        _mint(msg.sender, amount_);
    }
}
