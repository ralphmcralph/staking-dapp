// SPDX-License-Identifier: LGPL-3.0-only

pragma solidity 0.8.24;

import "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

// Staking fixed amount: 10 tokens
// Staking reward period: 1 day

contract StakingApp is Ownable {
    // === Variables ===
    address public stakingToken;
    uint256 public stakingPeriod;
    uint256 public fixedStakingAmount;
    uint256 public rewardPerPeriod;

    // === Mappings ===
    mapping(address => uint256) public tokenBalance;
    mapping(address => uint256) public depositTime;

    // === Events ===
    event ChangeStakingPeriod(uint256 newStakingPeriod_);
    event TokensDeposited(address user_, uint256 tokenAmount_);
    event TokensWithdraw(address user_, uint256 tokenAmount_);
    event RewardsClaimed(address user_, uint256 rewardAmount_);
    event EtherReceived(uint256 amount_);

    // === Constructor ===
    constructor(
        address stakingToken_,
        uint256 stakingPeriod_,
        uint256 fixedStakingAmount_,
        uint256 rewardPerPeriod_,
        address owner_
    ) Ownable(owner_) {
        stakingToken = stakingToken_;
        stakingPeriod = stakingPeriod_;
        fixedStakingAmount = fixedStakingAmount_;
        rewardPerPeriod = rewardPerPeriod_;
    }

    // === External functions ===
    // Deposit tokens
    function depositTokens(uint256 tokenAmount_) external {
        require(tokenAmount_ == fixedStakingAmount, "Incorrect Amount");
        require(tokenBalance[msg.sender] == 0, "User already deposited");

        IERC20(stakingToken).transferFrom(msg.sender, address(this), tokenAmount_);

        tokenBalance[msg.sender] += tokenAmount_;
        depositTime[msg.sender] = block.timestamp;

        emit TokensDeposited(msg.sender, tokenAmount_);
    }

    // Withdraw tokens
    function withdrawTokens() external {
        // CEI Pattern
        uint256 tokenBalance_ = tokenBalance[msg.sender];
        tokenBalance[msg.sender] = 0;

        IERC20(stakingToken).transfer(msg.sender, tokenBalance_);

        emit TokensWithdraw(msg.sender, fixedStakingAmount);
    }

    // Claim rewards
    function claimRewards() external {
        // Check balance
        require(tokenBalance[msg.sender] == fixedStakingAmount, "User is not staking tokens");

        // Calculate reward amount
        uint256 elapsedPeriod = block.timestamp - depositTime[msg.sender];

        require(elapsedPeriod >= stakingPeriod, "Cannot claim rewards yet");

        // Update state
        depositTime[msg.sender] = block.timestamp;

        // Transfer rewards
        (bool success,) = msg.sender.call{value: rewardPerPeriod}("");

        require(success, "Transfer failed");

        emit RewardsClaimed(msg.sender, rewardPerPeriod);
    }

    function changeStakingPeriod(uint256 newStakingPeriod_) external onlyOwner {
        stakingPeriod = newStakingPeriod_;
        emit ChangeStakingPeriod(newStakingPeriod_);
    }

    receive() external payable onlyOwner {
        emit EtherReceived(msg.value);
    }
}
