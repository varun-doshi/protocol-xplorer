// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "../lib/forge-std/src/Script.sol";
import "../src/CollateralLending.sol";

contract LendingScript is Script {
    function setUp() public {}

    function run() public {
        uint privateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(privateKey);
        CollateralLending lending = new CollateralLending(
            0x2a6811ee59B4A6FB2Ef43c15502fA3eE638AF274
        );
        vm.stopBroadcast();
    }
}
