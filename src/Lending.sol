// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract Lending {
    mapping(address => uint256) public deposited_balances;
    mapping(address => uint256) public borrower_balances;

    function deposit() public payable {
        require(msg.value > 0, "Amount cannot be 0");
        (bool sent, ) = payable(address(this)).call{value: msg.value}("");
        require(sent, "Failed to send Ether");
        deposited_balances[msg.sender] += msg.value;
    }

    function withdraw(uint256 amount) public {
        require(deposited_balances[msg.sender] >= amount, "Not enough balance");
        deposited_balances[msg.sender] -= amount;
        (bool sent, ) = payable(msg.sender).call{value: amount}("");
        require(sent, "Failed to withdraw Ether");
    }

    function borrow(uint256 amount) public {
        require(address(this).balance > amount, "Not enough balance");
        borrower_balances[msg.sender] += amount;
        (bool sent, ) = payable(msg.sender).call{value: amount}("");
        require(sent, "Failed to withdraw Ether");
    }

    function repay(uint amount) public payable {
        require(
            amount == borrower_balances[msg.sender],
            "Please repay complete amount!"
        );
        (bool sent, ) = address(this).call{value: amount}("");
        require(sent, "Failed to withdraw Ether");
        borrower_balances[msg.sender] = 0;
    }

    receive() external payable {}
}
