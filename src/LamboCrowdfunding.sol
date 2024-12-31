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
    uint256 public constant INVESTMENT_AMOUNT = 0.1 ether;  // Fixed investment amount
    
    mapping(address => bool) public whitelist;  // Whitelist mapping
    
    event FundReceived(address indexed sender, uint256 amount);
    event WhitelistUpdated(address[] users, bool status);
    
    constructor(
        uint256 _targetAmount,
        address initialOwner
    ) Ownable(initialOwner) {
        require(_targetAmount > 0, "Target amount must be greater than 0");
        targetAmount = _targetAmount;
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

    // Receive ETH function
    receive() external payable {
        require(!isClosed, "Crowdfunding is closed");
        require(whitelist[msg.sender], "Address not whitelisted");
        require(msg.value == INVESTMENT_AMOUNT, "Must send exactly 0.1 ETH");
        
        uint256 newTotal = raisedAmount + msg.value;
        require(newTotal <= targetAmount, "Target amount exceeded");
        
        raisedAmount += msg.value;
        whitelist[msg.sender] = false;  // Remove from whitelist after investment
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
} 