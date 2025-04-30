// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract FitechStaking {
    IERC20 public rewardsToken;
    uint256 reward = 10;
    uint256 totalStaked;
    address owner;

    struct User {
        uint256 amount;
        uint256 duration;
        uint256 stakedTime;
        uint256 unStakeTime;
        bool claimed;
    }

    mapping(address => User) private userStake;
    mapping(address => uint) private stakedAmountByUser;

    event Staked(address indexed _user, uint256 _amount, uint256 stakedTime);
    event unStaked(
        address indexed _user,
        uint256 _amount,
        uint256 unstakedTime
    );

    constructor(address _rewardToken) {
        rewardsToken = IERC20(_rewardToken);
        owner = msg.sender;
        rewardsToken.transferFrom(msg.sender, address(this), 1000 * 10 ** 18);
    }

    function stake(uint256 _amount) public payable {
        require(_amount != 0, "you can not stake zero ethereum");
        
     
    }



    // function stake(uint256 _amount, uint256 _durationInDay) public payable  {
    //     require(_amount != 0, "you can not stake zero ethereum");
    //     // require(condition);
    // }
}
