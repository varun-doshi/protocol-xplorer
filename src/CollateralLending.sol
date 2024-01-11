// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC20} from "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

/*
erc20 token=MTK
let us assume value of 1 MTK = 1 ETH
user submits MTK as collat -> can lend ETH
loan-to-value= 80%
this means user can borrow upto 80% of the value of his submitted MTK
if user submits MTK=500
=> Maximum amount user can borrow = 80% of 500 = 400 worth of ETH

*/

contract CollateralLending {
    mapping(address => uint256) public deposited_amount;
    mapping(address => uint256) public borrowed_amount;
    IERC20 public token;
    uint256 public constant LTV = 80;
    uint256 public constant PRICE = 1 ether;

    modifier isNotZeroAmount(uint256 amount) {
        require(amount > 0, "Amount cannot be 0");
        _;
    }

    error CollateralLending_WrongAmunt();
    error CollateralLending_CannotLiquidate();

    // EVENTS
    event Deposit(address indexed user, uint256 indexed amount);

    constructor(address erc20Token) {
        token = IERC20(erc20Token);
    }

    /// @notice User deposits collateral token
    /// @param amount how many collat tokens to deposit
    function depositToken(
        uint256 amount
    ) public payable isNotZeroAmount(amount) {
        require(amount > 0, "Amount cannot be 0");
        token.transferFrom(msg.sender, address(this), amount);
        deposited_amount[msg.sender] += amount;
        emit Deposit(msg.sender, amount);
    }

    /// @notice Withdraw deposited collateral token
    /// @param amount how many collat tokens to withdraw
    function withdrawToken(uint256 amount) public isNotZeroAmount(amount) {
        require(deposited_amount[msg.sender] >= amount, "Not enough balance");
        deposited_amount[msg.sender] -= amount;
        token.transfer(msg.sender, amount);
    }

    /// @notice Explain to an end user what this does
    /// @dev Send ETH to user in respect to deposited collateral(check for ltv first)
    /// @param amount amount of ETH requested(in ETH)
    function borrowEthForCollateral(
        uint256 amount
    ) external payable isNotZeroAmount(amount) {
        uint256 canBorrow = _canBorrow(msg.sender);
        require(amount <= canBorrow, "Please provide more collateral tokens");
        borrowed_amount[msg.sender] += amount * PRICE;
        (bool sent, ) = payable(msg.sender).call{value: amount * PRICE}("");
        require(sent, "Transfer not successful");
    }

    /// @notice Repay loan
    /// @dev Send ETH to contract to repay the loan
    /// @param amount amount of ETH to be repaid(in ETH)
    function repayETH(uint amount) public payable isNotZeroAmount(amount) {
        require(borrowed_amount[msg.sender] > 0, "Already repaid");
        require(
            amount <= borrowed_amount[msg.sender],
            "Please repay complete amount!"
        );
        uint256 totalRepayAmount = amount * PRICE;

        borrowed_amount[msg.sender] -= totalRepayAmount;
        if (msg.value != totalRepayAmount) {
            revert CollateralLending_WrongAmunt();
        }
    }

    function liquidateAsset(
        address borrower,
        uint256 tokenAmount
    ) external payable {
        require(
            borrowed_amount[borrower] >= tokenAmount,
            "Borrower did not borrow this amount"
        );
        bool canLiquidate = canBeLiquidated(borrower);
        require(canLiquidate, "Cannot be liquidated");
        uint256 collateralAmount = deposited_amount[msg.sender];
        if (msg.value < collateralAmount) {
            revert CollateralLending_CannotLiquidate();
        }
        token.transfer(msg.sender, collateralAmount);
    }

    function _canBorrow(address user) internal view returns (uint256) {
        uint256 depositedCollat = deposited_amount[user];
        uint256 maxAmtBorrowable = (depositedCollat * LTV) / 100;
        return maxAmtBorrowable;
    }

    function canBeLiquidated(address borrower) internal view returns (bool) {
        uint256 amtBorrowable = _canBorrow(borrower);
        if (amtBorrowable < 0) {
            return true;
        }
        return false;
    }

    receive() external payable {}
}
