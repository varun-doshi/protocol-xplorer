// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "../lib/forge-std/src/Test.sol";
import "../lib/forge-std/src/console.sol";
import {CollateralLending} from "../src/CollateralLending.sol";
import "../src/MyToken.sol";

contract CollateralLendingTest is Test {
    CollateralLending public lending;
    MyToken public myToken;
    address payable user1 = payable(makeAddr("Alice"));
    address payable user2 = payable(makeAddr("Bob"));

    // events
    error CollateralLending_WrongAmunt();

    function setUp() public {
        myToken = new MyToken("MyToken", "MTK");
        lending = new CollateralLending(address(myToken));
        vm.prank(user1);
        myToken.mint(user1, 100);
        vm.deal(address(lending), 100 ether);
    }

    function test_SetUp() public view {
        console.log(myToken.name());
        console.log(myToken.balanceOf(user1));
    }

    function test_deposit() public {
        vm.startPrank(user1);
        myToken.approve(address(lending), 50);
        lending.depositToken(50);
        vm.stopPrank();
        assertEq(myToken.balanceOf(user1), 50);
        assertEq(lending.deposited_amount(user1), 50);
        assertEq(myToken.balanceOf(address(lending)), 50);
    }

    function test_withdraw() public {
        test_deposit();
        vm.prank(user1);
        lending.withdrawToken(50);
        assertEq(myToken.balanceOf(user1), 100);
        assertEq(lending.deposited_amount(user1), 0);
        assertEq(myToken.balanceOf(address(lending)), 0);
    }

    function test_borrow_pass() public {
        test_deposit();
        vm.prank(user1);
        lending.borrowEthForCollateral(5);
        assertEq(lending.borrowed_amount(user1), 5 ether);
    }

    function test_borrow_fail() public {
        test_deposit();
        vm.prank(user2);
        vm.expectRevert();
        lending.borrowEthForCollateral(5);
    }

    function test_repay_complete() public {
        test_borrow_pass();
        vm.startPrank(user1);
        // myToken.approve(address(lending), 5);
        lending.repayETH{value: 5 ether}(5);
        vm.stopPrank();
        assertEq(lending.borrowed_amount(user1), 0);
        assertEq(address(lending).balance, 100 ether);
    }

    function test_repay_fail_incomplete() public {
        test_borrow_pass();
        vm.startPrank(user1);
        lending.repayETH{value: 4 ether}(4);
        vm.stopPrank();
        assertEq(lending.borrowed_amount(user1), 1 ether);
    }

    function test_repay_fail() public {
        test_borrow_pass();
        vm.startPrank(user1);
        vm.expectRevert();
        lending.repayETH{value: 4 gwei}(4);
        vm.stopPrank();
    }

    function testFuzz_deposit(uint256 amount) public {
        vm.assume(amount < 2 ** 96 && amount != 0);
        myToken.mint(user1, amount);
        vm.startPrank(user1);
        myToken.approve(address(lending), amount);
        lending.depositToken(amount);
        vm.stopPrank();
        assertEq(myToken.balanceOf(address(lending)), amount);
    }

    function test_ffi_sample() public {
        string[] memory inputs = new string[](2);
        inputs[0] = "cat";
        inputs[1] = "address.txt";
        bytes memory res = vm.ffi(inputs);
        address output = abi.decode(res, (address));
        console.log(output);
        assertEq(output, 0x965D1C9987BD2c34e151E63d60AFf8E9dB6b1561);
    }
}
