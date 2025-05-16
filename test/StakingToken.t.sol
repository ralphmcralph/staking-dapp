// SPDX-License-Identifier: LGPL-3.0-only

pragma solidity 0.8.24;

import "../src/StakingToken.sol";
import "forge-std/Test.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract StakingTokenTest is Test {
    
    StakingToken stakingToken;
    string name = "Staking Token";
    string token = "STK";
    address randomUser = vm.addr(1);

    function setUp() public {
        stakingToken = new StakingToken(name, token);
    }

    function testStakingTokenMintsCorrectly() public {
        vm.startPrank(randomUser);
        uint256 amount_ = 1 ether;

        // Previous token balance
        uint256 balanceBefore_ = IERC20(address(stakingToken)).balanceOf(randomUser);

        stakingToken.mint(amount_);

        // Token balance after

        uint256 balanceAfter_ = IERC20(address(stakingToken)).balanceOf(randomUser);

        assert(balanceAfter_ == balanceBefore_ + amount_);
        vm.stopPrank();
    }

}
