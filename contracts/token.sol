// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
pragma experimental ABIEncoderV2;


interface IERC20 {
    function balanceOf(address account) external view returns (uint256);

    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);

    function transferFrom(
        address owner,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
}

contract AirDrop {
    address public owner;
    address public reserveWallet;
    IERC20 Token;
    uint256 totalAmount;
    uint256 reserveAmount;
    uint256 totalClaimed;
    uint256 totalUsers;

    struct User {
        uint256 amount;
        uint256 withdrawtime;
        bool claimed; 
    }

    mapping(address => User) users;

    constructor(IERC20 tok) {
        owner = msg.sender;
        reserveWallet = msg.sender;
        Token = tok;
    }

    receive() external payable {}
 
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

   function Allocate(
    address[] memory _users,
    uint256[] memory _amounts,
    uint256[] memory _withdrawTime
  ) public onlyOwner {
    require(
        _users.length == _amounts.length,
        "Invalid data"
    );
    for (uint256 i = 0; i < _users.length; i++) {
        uint256 amount = _amounts[i];
        users[_users[i]].amount = amount;
        users[_users[i]].claimed = false;
        users[_users[i]].withdrawtime = _withdrawTime[i];
        totalAmount += amount;
        totalUsers += 1;
        
    }
}

    function claim() public {
        require(!users[msg.sender].claimed, "You have already claimed");
        require(
            block.timestamp >= users[msg.sender].withdrawtime,
            "time not reached"
        );
        uint256 reserveamount;
        uint256 useramount = users[msg.sender].amount;
        uint256 timepassed = block.timestamp - users[msg.sender].withdrawtime;
        if (timepassed > 1 days) {
            if (timepassed / 1 days > 5) {
                Token.transferFrom(owner, reserveWallet, useramount);
            } else {
                uint256 times = (timepassed / 1 days);
                reserveamount = (times *
                    ((users[msg.sender].amount * 20) / 100));
                useramount = users[msg.sender].amount - reserveamount;

                Token.transferFrom(owner, msg.sender, useramount);
                Token.transferFrom(owner, reserveWallet, reserveamount);
            }
        } else {
            Token.transferFrom(owner, msg.sender, useramount);
        }

        users[msg.sender].claimed = true;
        totalClaimed += useramount;
        reserveAmount += reserveamount;
    }


    function withdrawStuckAsset(
        uint256 _amount,
        address _tokenAddress
    ) external onlyOwner {
        if (_tokenAddress == address(0)) {
            payable(msg.sender).transfer(_amount);
        } else {
            IERC20(_tokenAddress).transfer(msg.sender, _amount);
        }
    }

    function multisender(
        address _token,
        address[] memory _users,
        uint256[] memory amounts
    ) external {
        require(_users.length == amounts.length, "Invalid data");
        for (uint256 i = 0; i < _users.length; i++) {
            IERC20(_token).transferFrom(msg.sender, _users[i], amounts[i]);
        }
    }
}