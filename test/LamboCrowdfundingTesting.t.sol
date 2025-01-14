// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import "../src/LamboCrowdfunding.sol";

contract LamboCrowdfundingTesting is Test {
    LamboCrowdfunding public crowdfunding;
    address public owner;
    address public user1;
    address public user2;
    uint256 public constant TARGET_AMOUNT = 100 ether; // 500 investments of 0.2 ETH

    function setUp() public {
        owner = makeAddr("owner");
        user1 = makeAddr("user1");
        user2 = makeAddr("user2");
        
        uint256 startTime = block.timestamp + 1 days;
        uint256 endTime = block.timestamp + 7 days;
        
        vm.prank(owner);
        crowdfunding = new LamboCrowdfunding(
            TARGET_AMOUNT,
            startTime,
            endTime,
            owner
        );

        vm.deal(user1, 1 ether);
        vm.deal(user2, 1 ether);
        
        // 将时间设置到 ICO 开始时间
        vm.warp(startTime);
    }

    function test_InitialState() public {
        assertEq(crowdfunding.targetAmount(), TARGET_AMOUNT);
        assertEq(crowdfunding.raisedAmount(), 0);
        assertEq(crowdfunding.isClosed(), false);
        assertEq(crowdfunding.owner(), owner);
    }

    function test_WhitelistUpdate() public {
        address[] memory users = new address[](2);
        users[0] = user1;
        users[1] = user2;

        vm.prank(owner);
        crowdfunding.updateWhitelist(users, true);

        assertTrue(crowdfunding.isWhitelisted(user1));
        assertTrue(crowdfunding.isWhitelisted(user2));
    }

    function test_OnlyWhitelistedCanInvest() public {
        vm.prank(user1);
        vm.expectRevert("Address not whitelisted");
        (bool success,) = address(crowdfunding).call{value: 0.2 ether}("");
    }

    function test_OnlyExactAmountAllowed() public {
        address[] memory users = new address[](1);
        users[0] = user1;
        
        vm.prank(owner);
        crowdfunding.updateWhitelist(users, true);

        vm.prank(user1);
        vm.expectRevert("Must send exactly 0.2 ETH");
        (bool success,) = address(crowdfunding).call{value: 0.3 ether}("");
    }

    function test_NormalInvestment() public {
        address[] memory users = new address[](1);
        users[0] = user1;
        
        vm.prank(owner);
        crowdfunding.updateWhitelist(users, true);

        vm.prank(user1);
        (bool success,) = address(crowdfunding).call{value: 0.2 ether}("");
        
        assertTrue(success);
        assertEq(crowdfunding.raisedAmount(), 0.2 ether);
    }

    function test_ReachTargetAndClose() public {
        // 创建500个用户地址
        address[] memory users = new address[](500);
        for(uint i = 0; i < 500; i++) {
            users[i] = makeAddr(string(abi.encodePacked("user", i)));
            vm.deal(users[i], 1 ether);  // 给每个用户1 ETH
        }
        
        vm.prank(owner);
        crowdfunding.updateWhitelist(users, true);

        for(uint i = 0; i < 500; i++) {
            vm.prank(users[i]);
            (bool success,) = address(crowdfunding).call{value: 0.2 ether}("");
            assertTrue(success);
        }
        
        assertEq(crowdfunding.raisedAmount(), TARGET_AMOUNT);
        assertTrue(crowdfunding.isClosed());
    }

    function test_CannotInvestTwice() public {
        address[] memory users = new address[](1);
        users[0] = user1;
        
        vm.prank(owner);
        crowdfunding.updateWhitelist(users, true);

        vm.prank(user1);
        (bool success,) = address(crowdfunding).call{value: 0.2 ether}("");
        assertTrue(success);

        // 尝试第二次投资
        vm.prank(user1);
        vm.expectRevert("Address not whitelisted");
        (bool failed,) = address(crowdfunding).call{value: 0.2 ether}("");
    }
}
