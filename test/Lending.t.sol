// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "../lib/forge-std/src/Test.sol";
import "../lib/forge-std/src/console.sol";
import {Lending} from "../src/Lending.sol";

contract LendingTest is Test {
    Lending public lending;
    address payable user1;
    address payable user2;

    function setUp() public {
        lending = new Lending();
        vm.deal(user1, 5 ether);
    }

    function testSmoke() public {
        assertEq(user1.balance, 5 ether);
    }

    function testDeposit() public {
        vm.prank(user1);
        lending.deposit{value: 1 ether}();
        uint256 expected = lending.deposited_balances(user1);
        assertEq(expected, 1 ether);
        assertEq(address(lending).balance, 1 ether);
    }

    function test_withdraw_after_deposit() public {
        testDeposit();
        assertEq(user1.balance, 4 ether);
        vm.prank(user1);
        lending.withdraw(1 ether);
        assertEq(user1.balance, 5 ether);
    }

    function test_failwithdraw_after_deposit() public {
        testDeposit();
        assertEq(user1.balance, 4 ether);
        vm.prank(user1);
        lending.withdraw(2 ether);
        assertEq(user1.balance, 4 ether);
    }
}
