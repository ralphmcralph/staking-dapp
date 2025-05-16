// SPDX-License-Identifier: LGPL-3.0-only

pragma solidity 0.8.24;

import "../src/StakingApp.sol";
import "../src/StakingToken.sol";
import "forge-std/Test.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract StakingAppTest is Test {
    StakingApp stakingApp;
    StakingToken stakingToken;

    // Staking Token parameters
    string tokenName = "Staking Token";
    string tokenSymbol = "STK";

    // Staking App parameters
    uint256 stakingPeriod = 1000000000000;
    uint256 newStakingPeriod = 1;
    uint256 fixedStakingAmount = 10;
    uint256 rewardPerPeriod = 1 ether;
    address owner = vm.addr(1);

    address randomUser = vm.addr(2);

    function setUp() public {
        stakingToken = new StakingToken(tokenName, tokenSymbol);
        stakingApp = new StakingApp(address(stakingToken), stakingPeriod, fixedStakingAmount, rewardPerPeriod, owner);
    }

    function testStakingTokenCorrectlyDeployed() external view {
        assert(address(stakingToken) != address(0));
    }

    function testStakingAppCorrectlyDeployed() external view {
        assert(address(stakingApp) != address(0));
    }

    function testWhenNotOwnerChangeStakingPeriod() external {
        vm.startPrank(randomUser);
        vm.expectRevert();
        stakingApp.changeStakingPeriod(newStakingPeriod);
        vm.stopPrank();
    }

    function testChangeStakingPeriod() external {
        vm.startPrank(owner);
        assert(stakingApp.stakingPeriod() != newStakingPeriod);
        stakingApp.changeStakingPeriod(newStakingPeriod);
        vm.stopPrank();

        assert(stakingApp.stakingPeriod() == newStakingPeriod);
    }

    function testContractReceivesETH() external {
        uint256 etherValue = 1 ether;

        uint256 balanceBefore = address(stakingApp).balance;
        vm.deal(owner, etherValue);

        vm.startPrank(owner);
        (bool success,) = address(stakingApp).call{value: etherValue}("");
        require(success, "Transfer failed");
        vm.stopPrank();

        uint256 balanceAfter = address(stakingApp).balance;

        assert(balanceAfter == balanceBefore + etherValue);
    }

    function testContractNotReceivesETHWhenNotOwner() external {
        uint256 etherValue = 1 ether;

        vm.deal(randomUser, etherValue);

        vm.startPrank(randomUser);
        vm.expectRevert();
        (bool success,) = address(stakingApp).call{value: etherValue}("");
        require(success, "Transfer failed");
        vm.stopPrank();
    }

    function testDepositTokensWhenIncorrectAmountShouldRevert() external {
        vm.startPrank(randomUser);
        vm.expectRevert("Incorrect Amount");
        stakingApp.depositTokens(fixedStakingAmount + 1);
        vm.stopPrank();
    }

    function testDepositTokens() external {
        vm.startPrank(randomUser);

        uint256 tokenBalanceBefore = stakingApp.tokenBalance(randomUser);
        uint256 timestampBefore = stakingApp.depositTime(randomUser);

        uint256 tokenAmount = stakingApp.fixedStakingAmount();
        stakingToken.mint(tokenAmount);

        IERC20(stakingToken).approve(address(stakingApp), tokenAmount);

        stakingApp.depositTokens(tokenAmount);
        uint256 tokenBalanceAfter = stakingApp.tokenBalance(randomUser);
        uint256 timestampAfter = stakingApp.depositTime(randomUser);

        assert(tokenBalanceAfter == tokenBalanceBefore + tokenAmount);
        assert(timestampBefore == 0);
        assert(timestampAfter == block.timestamp);
        vm.stopPrank();
    }

    function testUserCannotDepositTokensMoreThanOnce() external {
        vm.startPrank(randomUser);

        uint256 tokenBalanceBefore = stakingApp.tokenBalance(randomUser);
        uint256 timestampBefore = stakingApp.depositTime(randomUser);

        uint256 tokenAmount = stakingApp.fixedStakingAmount();
        stakingToken.mint(tokenAmount * 2);

        IERC20(stakingToken).approve(address(stakingApp), tokenAmount);

        stakingApp.depositTokens(tokenAmount);
        uint256 tokenBalanceAfter = stakingApp.tokenBalance(randomUser);
        uint256 timestampAfter = stakingApp.depositTime(randomUser);

        assert(tokenBalanceAfter == tokenBalanceBefore + tokenAmount);
        assert(timestampBefore == 0);
        assert(timestampAfter == block.timestamp);

        IERC20(stakingToken).approve(address(stakingApp), tokenAmount);
        vm.expectRevert("User already deposited");
        stakingApp.depositTokens(tokenAmount);

        vm.stopPrank();
    }

    function testCanOnlyWithDrawZeroWithoutDeposit() external {
        vm.startPrank(randomUser);
        uint256 tokenBalanceBefore = stakingApp.tokenBalance(randomUser);
        stakingApp.withdrawTokens();
        uint256 tokenBalanceAfter = stakingApp.tokenBalance(randomUser);
        vm.stopPrank();

        assert(tokenBalanceAfter == tokenBalanceBefore);
    }

    function testWithDraw() external {
        vm.startPrank(randomUser);

        uint256 tokenAmount = stakingApp.fixedStakingAmount();
        stakingToken.mint(tokenAmount);

        IERC20(stakingToken).approve(address(stakingApp), tokenAmount);

        stakingApp.depositTokens(tokenAmount);
        uint256 tokenBalanceBefore = stakingApp.tokenBalance(randomUser);

        stakingApp.withdrawTokens();
        uint256 tokenBalanceAfter = stakingApp.tokenBalance(randomUser);

        vm.stopPrank();

        assert(tokenBalanceBefore == tokenAmount);
        assert(tokenBalanceAfter == 0);
    }

    function testCannotClaimRewardsIfNotStaking() external {
        vm.startPrank(randomUser);
        vm.expectRevert("User is not staking tokens");
        stakingApp.claimRewards();
        vm.stopPrank();
    }

    function testCannotClaimRewardsIfNotEnoughElapsedTime() external {
        vm.startPrank(randomUser);

        uint256 tokenAmount = stakingApp.fixedStakingAmount();
        stakingToken.mint(tokenAmount);

        IERC20(stakingToken).approve(address(stakingApp), tokenAmount);

        stakingApp.depositTokens(tokenAmount);

        vm.expectRevert("Cannot claim rewards yet");
        stakingApp.claimRewards();

        vm.stopPrank();
    }

    function testClaimRewardsShouldRevertIfNoEther() external {
        vm.startPrank(randomUser);

        uint256 tokenAmount = stakingApp.fixedStakingAmount();
        stakingToken.mint(tokenAmount);

        IERC20(stakingToken).approve(address(stakingApp), tokenAmount);

        stakingApp.depositTokens(tokenAmount);

        vm.warp(block.timestamp + stakingApp.stakingPeriod());

        vm.expectRevert("Transfer failed");
        stakingApp.claimRewards();

        vm.stopPrank();
    }

    function testClaimRewards() external {
        uint256 etherValue = 1 ether;

        vm.deal(owner, etherValue);

        vm.startPrank(owner);
        (bool success,) = address(stakingApp).call{value: etherValue}("");
        require(success, "Transfer failed");
        uint256 balanceBefore = address(stakingApp).balance;
        vm.stopPrank();

        vm.startPrank(randomUser);

        uint256 tokenAmount = stakingApp.fixedStakingAmount();
        stakingToken.mint(tokenAmount);

        IERC20(stakingToken).approve(address(stakingApp), tokenAmount);

        stakingApp.depositTokens(tokenAmount);

        vm.warp(block.timestamp + stakingApp.stakingPeriod());

        uint256 userBalanceBefore = address(randomUser).balance;

        stakingApp.claimRewards();

        uint256 userBalanceAfter = address(randomUser).balance;

        assert(stakingApp.depositTime(randomUser) == block.timestamp);
        assert(userBalanceAfter == userBalanceBefore + stakingApp.rewardPerPeriod());

        vm.stopPrank();

        uint256 balanceAfter = address(stakingApp).balance;

        assert(balanceAfter + stakingApp.rewardPerPeriod() == balanceBefore);
    }
}
