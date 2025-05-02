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
        bool active;
    }

    mapping(address => User) private userStake;
    mapping(address => uint256) private stakedAmountByUser;
    mapping(address => uint256) private rewardAmountByUser;

    event Staked(address indexed _user, uint256 _amount, uint256 stakedTime);
    event unStaked(
        address indexed _user,
        uint256 _amount,
        uint256 unstakedTime
    );

    constructor(address _rewardToken) {
        rewardsToken = IERC20(_rewardToken);
        owner = msg.sender;
    }


    function stake(uint256 _durationInDay) external payable {
        require(msg.value != 0, "Staking amount can not be zero");
        require(_durationInDay != 0, "diration can not be zero");
        require(msg.sender != address(0), "invalid address");

        uint256 _amount = msg.value;
        require(
            !userStake[msg.sender].active,
            "you have an active stake please try updatingstake instead"
        );

        userStake[msg.sender] = User({
            amount: _amount,
            duration: (_durationInDay * 1 days),
            stakedTime: block.timestamp,
            unStakeTime: block.timestamp + (_durationInDay * 1 days),
            active: true
        });

        stakedAmountByUser[msg.sender] += _amount;
        totalStaked += _amount;

        emit Staked(msg.sender, _amount, block.timestamp);
    }

     function updatStaking() external payable {
        require(msg.value != 0, "you can not stake zero ethereum");
        require(msg.sender != address(0), "invalid address");

        User storage user = userStake[msg.sender];

        user.amount += msg.value;
    }

    function getUserTotalStakeAmount(address _user) public view  returns (uint) {

uint user = rewardAmountByUser[_user];

// require(, message);

        return rewardAmountByUser[_user];
        
    }

    function withdraw() external {}
}
