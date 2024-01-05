// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {IERC20} from "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract ERC20Lending {
    mapping(address => uint256) public deposited_balances;
    mapping(address => uint256) public borrower_balances;
    IERC20 public token;

    constructor(address erc20Token) {
        token = IERC20(erc20Token);
    }

    function depositToken(uint256 amount) public payable {
        require(amount > 0, "Amount cannot be 0");
        token.transferFrom(msg.sender, address(this), amount);
        deposited_balances[msg.sender] += amount;
    }

    function withdrawToken(uint256 amount) public {
        require(deposited_balances[msg.sender] >= amount, "Not enough balance");
        deposited_balances[msg.sender] -= amount;
        token.transfer(msg.sender, amount);
    }

    function borrowToken(uint256 amount) public {
        require(token.balanceOf(address(this)) > amount, "Not enough balance");
        borrower_balances[msg.sender] += amount;
        token.transfer(msg.sender, amount);
    }

    function repayToken(uint amount) public payable {
        require(borrower_balances[msg.sender] > 0, "Already repaid");
        require(
            amount <= borrower_balances[msg.sender],
            "Please repay complete amount!"
        );
        token.transferFrom(msg.sender, address(this), amount);
        borrower_balances[msg.sender] -= amount;
    }

    receive() external payable {}
}
