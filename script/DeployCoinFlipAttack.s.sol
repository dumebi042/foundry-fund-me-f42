// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {CoinFlipAttack} from "../src/CoinFlipAttack.sol";

contract DeployCoinFlipAttack is Script {
    function run() external returns (CoinFlipAttack) {
        address target = vm.envAddress("TARGET");

        vm.startBroadcast();
        CoinFlipAttack attacker = new CoinFlipAttack(target);
        vm.stopBroadcast();

        return attacker;
    }
}
