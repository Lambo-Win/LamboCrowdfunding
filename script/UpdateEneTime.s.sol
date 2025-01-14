// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import "../src/LamboCrowdfunding.sol";

import "forge-std/console2.sol";

contract UpdateEneTime is Script {
    // forge script script/UpdateEneTime.s.sol:UpdateEneTime --rpc-url https://eth-sepolia.public.blastapi.io --broadcast -vvvv --legacy

    function run() external {
                
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        address deployerAddress = vm.addr(privateKey);
        vm.startBroadcast(privateKey);
        LamboCrowdfunding lamboCrowFunding = LamboCrowdfunding(payable(0x7b27bBcfF04EC1C62EBe9206091C51d4c92CA3CC));

        lamboCrowFunding.updateTimeLimits(0x6785d660, block.timestamp + 1 days);
        vm.stopBroadcast();
    }
}