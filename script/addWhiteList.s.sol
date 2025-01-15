// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import "../src/LamboCrowdfunding.sol";

import "forge-std/console2.sol";

contract AddWhiteList is Script {
    address multiSign;
    // forge script script/addWhiteList.s.sol:AddWhiteList --rpc-url https://eth.llamarpc.com --broadcast -vvvv --legacy
    function run() external {
        
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        address deployerAddress = vm.addr(privateKey);
        vm.startBroadcast(privateKey);

        // Testnet, set multiSign as deployer
        // 0xdced556d5bf59bf54aa598b0e108fc49907c043b
        // 0x807a16f89bad7df384da4142e5177362670eb3b8
        // 0xc13311e81622ddea3282428348e7356c44decb3c
        // 0x2fc25088a8d93f10df697664beea5c23f721a230
        // 0x6df71940a2892c9b1b121d98be07a5a7e8856dd6
        // 0xc730a3f7d9e4535c9df88116b0155c3fa0ff8ef6
        // 0xba19367cdbb2262aaa31e3b4e694df3618481e53
        // 0x68e6cce918c80fb9eb7833eb719964ee86afe4c6
        // 0xb8c2be97e78f06e8d7a7c046f8dd4b0f17a6ebcc
        LamboCrowdfunding lamboCrowFunding = LamboCrowdfunding(payable(0xDe577025090B7187f25cb9190f1bFad9cEF00666));
        address[] memory users = new address[](2);
        users[0] = 0xd8bBAb5ABec2768444ee30920F52F1D3575dDe2c;
        users[1] = 0xacc79c9a29074AFD0216A2a2C3E080E622BB62ce;
        
        // users[0] = 0x85BCe97224ceC0884D9ACa9A961c46b084ecb215;
        // users[1] = 0xd8bBAb5ABec2768444ee30920F52F1D3575dDe2c;
        // users[2] = 0xacc79c9a29074AFD0216A2a2C3E080E622BB62ce;
        // users[3] = 0x85fe1d14B95ce466b4450b863723D14DAFB11CDB;
        // users[4] = 0x1A2a9b99293AF505799Caad02362883BC31d1e2A;

        // users[0] = 0xdCeD556D5Bf59Bf54aa598b0e108fc49907C043B;
        // users[1] = 0x807A16f89BAd7Df384dA4142e5177362670Eb3B8;
        // users[2] = 0xC13311e81622DDeA3282428348e7356c44DeCB3c;
        // users[3] = 0x8F75C55Fa603097f72D8801FA3befe0Bd758a89B;

        // users[3] = 0x2fC25088a8D93f10DF697664bEeA5C23f721A230;
        // users[4] = 0x6DF71940a2892c9B1B121d98be07A5a7E8856dd6;
        // users[5] = 0xc730a3f7D9E4535c9dF88116B0155c3FA0Ff8Ef6;
        // users[6] = 0xbA19367Cdbb2262Aaa31e3B4E694df3618481e53;
        // users[7] = 0x68e6CCe918C80fb9EB7833eB719964eE86afe4C6;
        // users[8] = 0xb8C2bE97e78F06E8D7A7c046f8Dd4b0f17A6ebCC;
        // users[9] = deployerAddress;

        lamboCrowFunding.updateWhitelist(users, true);
        
        vm.stopBroadcast();

      
    }
}

