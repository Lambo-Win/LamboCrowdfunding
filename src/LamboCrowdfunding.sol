// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/*
                    Ohf                              thm       
                    Ohf                              thm       
                    !LLbhf                              thkLLi    
                    <hhhhf                              thhhh~    
                    ,((qhLf/                          /fLhp((,    
                    \xLhb{{:                    ,{{dhLx/       
                        |hhhh1IIIIIIIIIIIIIIIIIIII[qqqq)         
                    .,,,,thhbbJvvvvxrrrrrrrrrrrrrrrnvvvv[,,,,.    
                    <hhhhhhkvvvvvvv'               lvvvv0hhhh~    
                    <hhhhhhkvvvvt<<                 ''xv0hhhh~    
                (Jv<<<<nhkvvvvtii  1UUUU;   .UUUUf  rv(<<<<uJ|  
                jj\(]    |hkvvvvtii::nhhhh!   'hhhhY  rv-    ?(\jj
                cc~      |hkvvvvj[[>i/UUUUi^^^"UUUUxiinv-      <cc
                    ,:fhkvvvvvvv_~~~~~~~~~~~~~~~[vvvv]^^^^.    
                    OhhhkvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvI    
                fwwwwkhhhkvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvxr[  
                vvZhhhhhhwCCvvvvvvvvvj|(]]]]]]]]]]]]]]]]]]]]]rvj11
                hhhhhhhhhOvvvvvvvvvvv\[{\\\\[lllllllll(\\\(lltvvvv
                hhhhhhhhhOvvvvvvvvvvv\[\hhhhclllllllllqhhhwlltvvvvx
                hhhhhhhhhOvvvvvvvvvvv\[\hhhhclllllllllqhhhwlltvvvv
                hhhhhhhhhOvvvvvvvvvvv\[}||]-~lllllllll_---_lltvCdd
                hhhhhhhhhpO0vvvvvvvvvrt/[[_++++llllllllllli))xvLhh
                hhhhhhhhhhhkUUUUYvvvvvvn))}[[[[>>>>>>>>>~+]UUUUOhh  
                hhhhhhhhhhhhhhhhwvvvvvvvvv)[[[[[[[[[[[[[tvXhhhhhhh
                """""""""/hhhhhhhbbbbbbbbbddddddddddddddbbkhh-""""
                        !11111111111Jhhhhhhhhhhhhhhhhhhhhhhh~    
*/


import "@openzeppelin/contracts/access/Ownable.sol";

contract LamboCrowdfunding is Ownable {
    uint256 public immutable targetAmount;    // Target fundraising amount
    uint256 public raisedAmount;              // Amount raised so far
    bool public isClosed;                     // Whether the crowdfunding is closed
    uint256 public constant INVESTMENT_AMOUNT = 0.2 ether;  // Fixed investment amount
    uint256 public startTime;                 // ICO start timestamp
    uint256 public endTime;                   // ICO end timestamp
    
    mapping(address => bool) public whitelist;  // Whitelist mapping
    mapping(address => bool) public hasInvested; // Track if an address has invested

    event FundReceived(address indexed sender, uint256 amount);
    event WhitelistUpdated(address[] users, bool status);
    event TimeUpdated(uint256 newStartTime, uint256 newEndTime);
    
    constructor(
        uint256 _targetAmount,
        uint256 _startTime,
        uint256 _endTime,
        address initialOwner
    ) Ownable(initialOwner) {
        require(_targetAmount > 0, "Target amount must be greater than 0");
        require(_startTime < _endTime, "End time must be after start time");
        require(_startTime > block.timestamp, "Start time must be in future");
        targetAmount = _targetAmount;
        startTime = _startTime;
        endTime = _endTime;
    }

    // Batch update whitelist
    function updateWhitelist(address[] calldata _users, bool _status) external onlyOwner {
        for(uint i = 0; i < _users.length; i++) {
            whitelist[_users[i]] = _status;
        }
        emit WhitelistUpdated(_users, _status);
    }

    // Check if an address is whitelisted
    function isWhitelisted(address _user) public view returns (bool) {
        return whitelist[_user];
    }

    // View function to check if an address is whitelisted and has invested
    function checkWhitelistAndInvestmentStatus(address _user) public view returns (bool) {
        return whitelist[_user] && hasInvested[_user];
    }

    // Update ICO time limits
    function updateTimeLimits(uint256 _startTime, uint256 _endTime) external onlyOwner {
        require(_startTime < _endTime, "End time must be after start time");
        require(!isClosed, "Crowdfunding is closed");
        
        // If ICO hasn't started yet, we can update both times
        if (block.timestamp < startTime) {
            require(_startTime > block.timestamp, "Start time must be in future");
            startTime = _startTime;
            endTime = _endTime;
        } else {
            // If ICO has started, we can only extend the end time
            require(_endTime > endTime, "Can only extend end time");
            require(_startTime == startTime, "Cannot change start time after ICO begins");
            endTime = _endTime;
        }
        
        emit TimeUpdated(startTime, endTime);
    }

    // Receive ETH function
    receive() external payable {
        require(!isClosed, "Crowdfunding is closed");
        require(block.timestamp >= startTime, "ICO has not started");
        require(block.timestamp <= endTime, "ICO has ended");
        require(whitelist[msg.sender], "Address not whitelisted");
        require(!hasInvested[msg.sender], "Address has already invested");
        require(msg.value == INVESTMENT_AMOUNT, "Must send exactly 0.2 ETH");
        
        uint256 newTotal = raisedAmount + msg.value;
        require(newTotal <= targetAmount, "Target amount exceeded");
        
        raisedAmount += msg.value;
        hasInvested[msg.sender] = true; // Mark as invested
        emit FundReceived(msg.sender, msg.value);
        
        if (raisedAmount >= targetAmount) {
            isClosed = true;
        }
    }

    // Only owner can withdraw funds
    function withdraw() external onlyOwner {
        require(isClosed, "Crowdfunding is not closed");
        require(address(this).balance > 0, "No funds to withdraw");
        
        (bool success, ) = payable(owner()).call{value: address(this).balance}("");
        require(success, "Withdrawal failed");
    }

    // View the contract's ETH balance
    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    // View the start time
    function getStartTime() public view returns (uint256) {
        return startTime;
    }

    // View the end time
    function getEndTime() public view returns (uint256) {
        return endTime;
    }
} 