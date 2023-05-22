//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18; 
interface token {
    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address _owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
         uint256 value
    );
}

contract BigDaddy {
    token public BUSD;
    address dev = (0xb27A5715DeE0B91CC60da06c1bb860aBa44DB804);//for 5% dev fee
    
    address owner;
   
    uint256 public DEPOSIT_MIN_AMOUNT = 10 ether;
    uint256 public DEPOSIT_MAX_AMOUNT = 2000 ether;
    uint256[15] private REFERRAL_PERCENTS = [10,10,10,5,5,5,5,5,5,5,5,5,5,5,5];
    
    uint256 public totalUsers;
    uint256 public totalInvested;
    uint256 public totalWithdrawn;
    uint256 public totalDeposits;
    uint256 public TIME_STEP_ROI_PERCENTAGE = 10;
    uint256 public PERCENTS_DIVIDER = 100;

    uint256 public TIME_STEP = 100;
    uint256 private  ROI_PERCENTAGE = 200;
    uint256 private DIRECT_REFERRAL_PERCENTAGE = 10;
    address public defaultReferrer;
    
    



    struct Deposit {

        uint256 amount;
        uint256 withdrawn; 
        uint256 start; 
        uint256 endTime; 
    }

     struct User {
        Deposit[] deposits;
        address referrer;
        address []directs;
        uint256 levelbonus;
        uint256 levelbonuswithdrawn;
        uint256 directIncomewithdrawn;
        uint256[15] levelusers;
        uint256[15] levelincome;
        uint256 directIncome;
        uint256 players;
        uint256 matchingBusiness;
        bool referralBonusPaid;
    }
    
    mapping(address => User) public users;
    
    
    constructor(token _tokenAddress, address _defaultReferrer) {
        dev = (0xb27A5715DeE0B91CC60da06c1bb860aBa44DB804); //for 5% dev fee
        require(address(_tokenAddress) != address(0), "Token Address cannot be address 0");
        BUSD = _tokenAddress;
        defaultReferrer = _defaultReferrer;
        
}
    


  function register(address _referrer) public {
    require(users[msg.sender].referrer == address(0), "User is already registered");
    require(_referrer == defaultReferrer || users[_referrer].deposits.length >0, "Invalid referrer address");
    
    users[msg.sender].referrer = _referrer;
    
}



 function deposit(uint256 _amount) public {
    User storage user = users[msg.sender];
        
    require(user.referrer != address(0), "Please register first");
    require(BUSD.balanceOf(msg.sender) >= _amount, "Insufficient Balance");   

    require(_amount >= DEPOSIT_MIN_AMOUNT && _amount <= DEPOSIT_MAX_AMOUNT, "Deposit amount must be between 10 and 2000 BUSD");
    require(_amount % 10 == 0, "Deposit amount must be in multiples of 10");

    
    require(BUSD.transferFrom(msg.sender, address(this), _amount), "Failed to transfer BUSD");
    
       // add direct referral bonus
     if (user.referrer != defaultReferrer && users[user.referrer].deposits.length > 0 && !user.referralBonusPaid) {
        uint256 directReferralBonus = (_amount * DIRECT_REFERRAL_PERCENTAGE) / 100;
        users[user.referrer].directIncome += directReferralBonus;
        users[user.referrer].directs.push(msg.sender);
        user.referralBonusPaid = true;
    }

    uint256 systemFee = (_amount * 5) / 100;
    uint256 depositAmount = _amount - systemFee;

    if (user.deposits.length == 0) {
        totalUsers++;
    }

    user.deposits.push(Deposit(depositAmount, 0 , block.timestamp,block.timestamp + TIME_STEP));
    totalInvested += depositAmount;
    totalDeposits++;

    // transfer systemFee 
    if (systemFee > 0) {
        require(BUSD.transfer(dev, systemFee), "Failed to transfer system fee");
    }
}

    function getUserTotalDeposits(User storage user) internal view returns (uint256) {
        uint256 totalAmount;

       for (uint256 i = 0; i < user.deposits.length; i++) {
        totalAmount += user.deposits[i].amount;
    }

      return totalAmount;
    }
    

    function getTotalReferralBonus(address user) public view returns (uint256) {
        uint256 totalBonus;

        for (uint256 i = 0; i < REFERRAL_PERCENTS.length; i++) {
            uint256 bonus = getUserLevelIncome(user, i);
            totalBonus += bonus;
        }

        return totalBonus;
    }

    function getUserLevelIncome(address user, uint256 level) public view returns (uint256) {
        User storage u = users[user];
        return u.levelincome[level];
    }

    function getContractBalance() public view returns (uint256) {
        return BUSD.balanceOf(address(this));
    }


    function getuserDirects(address _user)public view returns (address[] memory){
        return users[_user].directs;
    }

    function checkYourTeam(address _user) public view returns (uint256[15] memory levels,
       
        uint256[15] memory levelincomes, 
        uint256 directIncomes, 
        uint256 directsLenght,
        uint256 players,
        uint256 Business) {
    
      User storage user = users[_user];
        uint256[15] memory levelusers = user.levelusers;
        uint256[15] memory levelincome = user.levelincome;
        uint256 directIncome = user.directIncome;
        uint256 directs = user.directs.length;
        uint256 a =user.players;
        uint256 b = user.matchingBusiness;
     return (levelusers, levelincome, directIncome, directs,a,b);
    }

    function withdrawLevelBonus() private{
          User storage user = users[msg.sender];
          uint256 contractBalance = BUSD.balanceOf(address(this));
          require(contractBalance > 0, "Contract balance must be greater than 0");
          require(user.levelbonus > 0, "No level bonus to withdraw");

          uint256 amount = user.levelbonus;
          uint256 a= user.directIncome;
          user.levelbonus = 0;
          user.directIncome=0;
          user.levelbonuswithdrawn = user.levelbonuswithdrawn + (amount);
          user.directIncomewithdrawn=user.directIncomewithdrawn+(a);
          totalWithdrawn = totalWithdrawn + (amount+a);

    require(BUSD.transfer(msg.sender, amount+a), "Failed to transfer BUSD");
 }

 function withdrawable(address user) public view returns (uint256){
        
        User storage a = users[user];
        uint256 amount = a.levelbonus - a.levelbonuswithdrawn;
        uint256 b= a.directIncome - a.directIncomewithdrawn;
        return amount+b;
    }


    function withdraw() public {
    User storage user = users[msg.sender];
    require(user.deposits.length > 0, "No deposits found");

    Deposit storage latestDeposit = user.deposits[user.deposits.length - 1];
    require(block.timestamp >= latestDeposit.endTime, "Deposit not matured yet");

    uint256 withdrawables = getUserDividendsWithdrawable(msg.sender);
    require(withdrawables > 0, "No dividends available for withdrawal");

    if (user.levelbonus > 0) {
        withdrawLevelBonus();
    }

    uint256 withdrawnAmount = withdrawables;
    if (withdrawables > latestDeposit.withdrawn) {
        withdrawnAmount = withdrawables - latestDeposit.withdrawn;
        latestDeposit.withdrawn = withdrawables;
    }

    require(BUSD.transfer(msg.sender, withdrawnAmount), "Failed to transfer BUSD");
    latestDeposit.endTime += TIME_STEP;
}


 function getUserDividendsWithdrawable(address userAddress) public view returns (uint256) {
        User storage user = users[userAddress];
        uint256 totalDividends;
        uint256 dividends;
        for (uint256 i = 0; i < user.deposits.length; i++) {
            if (
                user.deposits[i].withdrawn < (user.deposits[i].amount * (ROI_PERCENTAGE)) / (PERCENTS_DIVIDER)
            ) {
                dividends = (((user.deposits[i].amount * (TIME_STEP_ROI_PERCENTAGE)) /
                        (PERCENTS_DIVIDER)) *(block.timestamp - (user.deposits[i].start))) / (TIME_STEP);
                if (
                    user.deposits[i].withdrawn + (dividends) >(user.deposits[i].amount * (ROI_PERCENTAGE)) /(PERCENTS_DIVIDER)
                ) {
                    dividends = ((user.deposits[i].amount * (ROI_PERCENTAGE)) /(PERCENTS_DIVIDER)) -(user.deposits[i].withdrawn);
                }

                totalDividends = totalDividends + (dividends);
            }
        }

        return (totalDividends);
    }
   
      
    function getUserInformation(address userAddress, uint256 index) public view returns (
        uint256 amount,
        uint256 withdrawn,
        uint256 start,
        uint endTime
    ) {
        require(index < users[userAddress].deposits.length, "Invalid deposit index");
        Deposit storage latestDeposit = users[userAddress].deposits[index];
        require(latestDeposit.start > 0, "Invalid deposit data");
        return (latestDeposit.amount, latestDeposit.withdrawn, latestDeposit.start, latestDeposit.endTime);
    }

    function checkUserDepositLength() public view returns (uint256) {
        return users[msg.sender].deposits.length;
    }

}

    















