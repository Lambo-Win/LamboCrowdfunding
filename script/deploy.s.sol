// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import "../src/LamboCrowdfunding.sol";

import "forge-std/console2.sol";

contract DeployContract is Script {
    address multiSign;
    // forge script script/deploy.s.sol:DeployContract --rpc-url https://eth-sepolia.public.blastapi.io --broadcast -vvvv --legacy
    function run() external {
        
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        address deployerAddress = vm.addr(privateKey);
        vm.startBroadcast(privateKey);

        // Testnet, set multiSign as deployer
        LamboCrowdfunding lamboCrowFunding = new LamboCrowdfunding(
            1 ether,
            deployerAddress
        );

        console2.log("contract address: ", address(lamboCrowFunding));
        
        vm.stopBroadcast();

      
    }
}

