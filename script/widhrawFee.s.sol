// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import "../src/LamboCrowdfunding.sol";

import "forge-std/console2.sol";

contract Withdrawfee is Script {
    // forge script script/widhrawFee.s.sol:Withdrawfee --rpc-url https://eth-sepolia.public.blastapi.io --broadcast -vvvv --legacy

    function run() external {
                
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        address deployerAddress = vm.addr(privateKey);
        vm.startBroadcast(privateKey);
        LamboCrowdfunding lamboCrowFunding = LamboCrowdfunding(payable(0x3Fe36fE2417049CC50Fcc1a475626246C5130452));

        lamboCrowFunding.withdraw();
        vm.stopBroadcast();
    }
}