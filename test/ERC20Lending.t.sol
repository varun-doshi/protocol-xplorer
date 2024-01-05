// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "../lib/forge-std/src/Test.sol";
import "../lib/forge-std/src/console.sol";
import {ERC20Lending} from "../src/ERC20Lending.sol";
import "../src/MyToken.sol";

contract LendingTest is Test {
    ERC20Lending public lending;
    MyToken public myToken;
    address payable user1 = payable(makeAddr("Alice"));
    address payable user2 = payable(makeAddr("Bob"));

    function setUp() public {
        myToken = new MyToken("MyToken", "MTK");
        lending = new ERC20Lending(address(myToken));
        vm.prank(user1);
        myToken.mint(user1, 100);
    }

    function testSmoke() public view {
        console.log(myToken.name());
        console.log(myToken.balanceOf(user1));
    }

    function test_deposit() public {
        vm.startPrank(user1);
        myToken.approve(address(lending), 50);
        lending.depositToken(50);
        vm.stopPrank();
        assertEq(myToken.balanceOf(user1), 50);
        assertEq(lending.deposited_balances(user1), 50);
        assertEq(myToken.balanceOf(address(lending)), 50);
    }

    function test_withdraw() public {
        test_deposit();
        vm.prank(user1);
        lending.withdrawToken(50);
        assertEq(myToken.balanceOf(user1), 100);
        assertEq(lending.deposited_balances(user1), 0);
        assertEq(myToken.balanceOf(address(lending)), 0);
    }

    function test_borrow() public {
        test_deposit();
        vm.prank(user2);
        lending.borrowToken(5);
        assertEq(myToken.balanceOf(user2), 5);
        assertEq(myToken.balanceOf(address(lending)), 45);
    }

    function test_repay() public {
        test_borrow();
        vm.startPrank(user2);
        myToken.approve(address(lending), 5);
        lending.repayToken(5);
        vm.stopPrank();
        assertEq(myToken.balanceOf(user2), 0);
        assertEq(myToken.balanceOf(address(lending)), 50);
    }
}
