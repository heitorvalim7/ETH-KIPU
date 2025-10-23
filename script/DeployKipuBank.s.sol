// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {KipuBank} from "../src/KipuBank.sol";

contract DeployKipuBank is Script {
    function run() external returns (KipuBank) {
        
        uint256 bankCap = vm.envUint("BANK_CAP");
        uint256 withdrawalLimit = vm.envUint("WITHDRAWAL_LIMIT");

        vm.startBroadcast();
        KipuBank kipuBank = new KipuBank(bankCap, withdrawalLimit);
        vm.stopBroadcast();

        return kipuBank;
    }
}