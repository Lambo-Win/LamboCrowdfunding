// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import "../src/LamboCrowdfunding.sol";

contract FuzzingTest is Test {
    LamboCrowdfunding public crowdfunding;
    address public owner;
    uint256 public constant INVESTMENT_AMOUNT = 0.2 ether;

    function setUp() public {
        owner = makeAddr("owner");
        vm.prank(owner);
        // 设置一个较大的目标金额以便进行模糊测试
        crowdfunding = new LamboCrowdfunding(1000 ether, owner);
    }

    // 测试随机地址的白名单添加和投资
    function testFuzz_WhitelistAndInvestment(address user) public {
        vm.assume(user != address(0) && user != owner);
        
        // 给测试用户足够的 ETH
        vm.deal(user, 1 ether);

        // 创建只包含测试用户的白名单数组
        address[] memory users = new address[](1);
        users[0] = user;

        // 添加到白名单
        vm.prank(owner);
        crowdfunding.updateWhitelist(users, true);
        
        // 验证初始状态
        assertTrue(crowdfunding.isWhitelisted(user));
        assertFalse(crowdfunding.hasInvested(user));

        // 模拟投资
        vm.prank(user);
        (bool success,) = address(crowdfunding).call{value: INVESTMENT_AMOUNT}("");
        assertTrue(success);

        // 验证投资后状态
        assertEq(crowdfunding.raisedAmount(), INVESTMENT_AMOUNT);
        assertTrue(crowdfunding.hasInvested(user));
        assertTrue(crowdfunding.isWhitelisted(user));  // 白名单状态应该保持不变
    }

    // 测试批量添加白名单
    function testFuzz_BatchWhitelist(address[] calldata users) public {
        vm.assume(users.length > 0 && users.length <= 1000);  // 限制数组大小
        
        // 过滤掉零地址和所有者地址
        for(uint i = 0; i < users.length; i++) {
            vm.assume(users[i] != address(0) && users[i] != owner);
        }

        // 批量添加白名单
        vm.prank(owner);
        crowdfunding.updateWhitelist(users, true);

        // 验证所有地址都在白名单中
        for(uint i = 0; i < users.length; i++) {
            assertTrue(crowdfunding.isWhitelisted(users[i]));
        }
    }

    // 测试随机金额的投资尝试
    function testFuzz_InvestmentAmount(uint256 amount, address user) public {
        vm.assume(user != address(0) && user != owner);
        vm.assume(amount != INVESTMENT_AMOUNT && amount > 0 && amount <= 1000 ether);
        
        // 给用户足够的 ETH
        vm.deal(user, amount);

        // 添加用户到白名单
        address[] memory users = new address[](1);
        users[0] = user;
        vm.prank(owner);
        crowdfunding.updateWhitelist(users, true);

        // 验证初始状态
        assertFalse(crowdfunding.hasInvested(user));

        // 尝试投资错误金额
        vm.prank(user);
        vm.expectRevert("Must send exactly 0.1 ETH");
        (bool success,) = address(crowdfunding).call{value: amount}("");

        // 验证状态没有改变
        assertFalse(crowdfunding.hasInvested(user));
    }

    // 测试目标金额达成后的投资尝试
    function testFuzz_InvestmentAfterTarget(uint256 numInvestors) public {
        vm.assume(numInvestors > 0 && numInvestors <= 10000);  // 限制投资者数量
        uint256 targetAmount = crowdfunding.targetAmount();
        uint256 maxInvestors = targetAmount / INVESTMENT_AMOUNT;
        
        // 如果生成的数量超过最大投资者数量，就使用最大数量
        if (numInvestors > maxInvestors) {
            numInvestors = maxInvestors;
        }

        // 创建投资者并添加到白名单
        address[] memory investors = new address[](numInvestors);
        for(uint i = 0; i < numInvestors; i++) {
            investors[i] = makeAddr(string(abi.encodePacked("investor", i)));
            vm.deal(investors[i], INVESTMENT_AMOUNT);
        }
        
        vm.prank(owner);
        crowdfunding.updateWhitelist(investors, true);

        // 进行投资直到达到目标
        for(uint i = 0; i < numInvestors; i++) {
            if (crowdfunding.raisedAmount() + INVESTMENT_AMOUNT <= targetAmount) {
                vm.prank(investors[i]);
                (bool success,) = address(crowdfunding).call{value: INVESTMENT_AMOUNT}("");
                assertTrue(success);
            }
        }

        // 创建新的投资者尝试投资
        address newInvestor = makeAddr("newInvestor");
        vm.deal(newInvestor, INVESTMENT_AMOUNT);
        
        address[] memory newInvestors = new address[](1);
        newInvestors[0] = newInvestor;
        
        vm.prank(owner);
        crowdfunding.updateWhitelist(newInvestors, true);

        // 尝试在目标达成后投资
        if (crowdfunding.isClosed()) {
            vm.prank(newInvestor);
            vm.expectRevert("Crowdfunding is closed");
            (bool success,) = address(crowdfunding).call{value: INVESTMENT_AMOUNT}("");
        }
    }

    // 测试重复投资
    function testFuzz_CannotInvestTwice(address user) public {
        vm.assume(user != address(0) && user != owner);
        
        // 给测试用户足够的 ETH
        vm.deal(user, 1 ether);

        // 添加用户到白名单
        address[] memory users = new address[](1);
        users[0] = user;
        vm.prank(owner);
        crowdfunding.updateWhitelist(users, true);

        // 第一次投资
        vm.prank(user);
        (bool success,) = address(crowdfunding).call{value: INVESTMENT_AMOUNT}("");
        assertTrue(success);
        assertTrue(crowdfunding.hasInvested(user));

        // 尝试第二次投资
        vm.prank(user);
        vm.expectRevert("Address has already invested");
        (bool failed,) = address(crowdfunding).call{value: INVESTMENT_AMOUNT}("");
    }

    // 测试检查白名单和投资状态
    function testFuzz_CheckWhitelistAndInvestmentStatus(address user) public {
        vm.assume(user != address(0) && user != owner);
        
        // 初始状态检查
        assertFalse(crowdfunding.checkWhitelistAndInvestmentStatus(user));

        // 添加到白名单
        address[] memory users = new address[](1);
        users[0] = user;
        vm.prank(owner);
        crowdfunding.updateWhitelist(users, true);

        // 只有白名单状态检查
        assertFalse(crowdfunding.checkWhitelistAndInvestmentStatus(user));

        // 投资后状态检查
        vm.deal(user, INVESTMENT_AMOUNT);
        vm.prank(user);
        (bool success,) = address(crowdfunding).call{value: INVESTMENT_AMOUNT}("");
        assertTrue(success);

        // 验证最终状态
        assertTrue(crowdfunding.checkWhitelistAndInvestmentStatus(user));
    }
}
