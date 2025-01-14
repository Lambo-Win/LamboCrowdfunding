// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import "../src/LamboCrowdfunding.sol";

contract TimeLimitTest is Test {
    LamboCrowdfunding public crowdfunding;
    address public owner;
    address public user1;
    uint256 public startTime;
    uint256 public endTime;
    uint256 public constant TARGET_AMOUNT = 100 ether;

    function setUp() public {
        owner = makeAddr("owner");
        user1 = makeAddr("user1");
        
        // Set timestamps
        startTime = block.timestamp + 1 days;
        endTime = block.timestamp + 7 days;
        
        vm.prank(owner);
        crowdfunding = new LamboCrowdfunding(
            TARGET_AMOUNT,
            startTime,
            endTime,
            owner
        );

        vm.deal(user1, 1 ether);
    }

    function test_InitialTimeSettings() public {
        assertEq(crowdfunding.startTime(), startTime);
        assertEq(crowdfunding.endTime(), endTime);
    }

    function test_CannotInvestBeforeStart() public {
        address[] memory users = new address[](1);
        users[0] = user1;
        
        vm.prank(owner);
        crowdfunding.updateWhitelist(users, true);

        vm.prank(user1);
        vm.expectRevert("ICO has not started");
        (bool success,) = address(crowdfunding).call{value: 0.2 ether}("");
    }

    function test_CannotInvestAfterEnd() public {
        address[] memory users = new address[](1);
        users[0] = user1;
        
        vm.prank(owner);
        crowdfunding.updateWhitelist(users, true);

        // Move timestamp after end time
        vm.warp(endTime + 1);

        vm.prank(user1);
        vm.expectRevert("ICO has ended");
        (bool success,) = address(crowdfunding).call{value: 0.2 ether}("");
    }

    function test_UpdateTimeLimits() public {
        uint256 newStartTime = startTime + 1 days;
        uint256 newEndTime = endTime + 7 days;

        vm.prank(owner);
        crowdfunding.updateTimeLimits(newStartTime, newEndTime);

        assertEq(crowdfunding.startTime(), newStartTime);
        assertEq(crowdfunding.endTime(), newEndTime);
    }

    function test_CannotUpdateStartTimeAfterStart() public {
        // Move to after start time
        vm.warp(startTime + 1);

        vm.prank(owner);
        vm.expectRevert("Cannot change start time after ICO begins");
        crowdfunding.updateTimeLimits(startTime + 1 days, endTime + 7 days);
    }

    function test_CanExtendEndTimeAfterStart() public {
        // Move to after start time
        vm.warp(startTime + 1);

        uint256 newEndTime = endTime + 7 days;
        
        vm.prank(owner);
        crowdfunding.updateTimeLimits(startTime, newEndTime);

        assertEq(crowdfunding.endTime(), newEndTime);
    }

    function test_NormalInvestmentDuringICO() public {
        address[] memory users = new address[](1);
        users[0] = user1;
        
        vm.prank(owner);
        crowdfunding.updateWhitelist(users, true);

        // Move to start time
        vm.warp(startTime);

        vm.prank(user1);
        (bool success,) = address(crowdfunding).call{value: 0.2 ether}("");
        assertTrue(success);
    }

    function testFuzz_UpdateTimeLimits(uint256 newStartTime, uint256 newEndTime) public {
        vm.assume(newStartTime > block.timestamp);
        vm.assume(newEndTime > newStartTime);
        vm.assume(newEndTime < type(uint256).max - 1 days);

        vm.prank(owner);
        crowdfunding.updateTimeLimits(newStartTime, newEndTime);

        assertEq(crowdfunding.startTime(), newStartTime);
        assertEq(crowdfunding.endTime(), newEndTime);
    }
} 