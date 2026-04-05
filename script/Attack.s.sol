// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {CoinFlipAttack} from "../src/CoinFlipAttack.sol";

contract AttackScript is Script {
    function run() external {
        address attacker = vm.envAddress("ATTACKER");

        vm.startBroadcast();
        CoinFlipAttack(attacker).attack();
        vm.stopBroadcast();
    }
}
