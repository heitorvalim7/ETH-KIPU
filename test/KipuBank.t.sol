// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {KipuBank} from "../src/KipuBank.sol";

/**
 * @title KipuBank Test Suite
 * @author heitorvalim7
 * @notice This contract contains all the tests for the KipuBank contract
 */
contract KipuBankTest is Test {
    // =================================================================
    // State Variables for Testing
    // =================================================================
    KipuBank private kipuBank;

    uint256 private constant BANK_CAP = 100 ether;
    uint256 private constant WITHDRAWAL_LIMIT = 1 ether;

    // =================================================================
    // Setup Function
    // =================================================================

    /**
     * @dev This function is called before each test case is run
     * It deploys a fresh instance of the KipuBank contract
     */
    function setUp() public {
        kipuBank = new KipuBank(BANK_CAP, WITHDRAWAL_LIMIT);
    }

    // =================================================================
    // Test Cases
    // =================================================================
    /**
     * @notice Tests if a user can successfully deposit ETH
     */
    function testDepositSucceeds() public {
        // -------------------------------------------------------------
        // Arrange: Set up the test scenario.
        // -------------------------------------------------------------
        uint256 depositAmount = 0.5 ether; // The amount Alice will deposit
        address alice = makeAddr("alice"); // Create a test user named "alice"
        vm.deal(alice, 10 ether);          // Fund Alice's account with 10 ETH

        // -------------------------------------------------------------
        // Act: Execute the function being tested.
        // -------------------------------------------------------------

        // Set up the event expectation BEFORE the action
        // "Foundry, on the next call, I expect this event to be emitted:"
        vm.expectEmit(true, true, false, true);
        emit KipuBank.Deposit(alice, depositAmount);

        // Now, Alice actually makes the deposit
        vm.prank(alice); // Impersonate Alice. The next call's msg.sender will be her address.
        kipuBank.deposit{value: depositAmount}(); // Alice calls the deposit function and sends ETH.

        // -------------------------------------------------------------
        // Assert: Check if the outcome is as expected
        // -------------------------------------------------------------
        assertEq(kipuBank.getBalanceOf(alice), depositAmount, "Balance should be updated");
        assertEq(kipuBank.s_depositCount(), 1, "Deposit count should be 1");
    }

    /**
     * @notice Tests if a user can successfully withdraw ETH
     */
    function testWithdrawSucceeds() public {
        // Arrange
        uint256 depositAmount = 0.5 ether;
        address alice = makeAddr("alice");
        vm.deal(alice, 10 ether);
        uint256 initialAliceBalance = alice.balance;

        // Alice first needs to deposit
        vm.prank(alice);
        kipuBank.deposit{value: depositAmount}();

        // Act
        // Set up the event expectation
        vm.expectEmit(true, true, false, true);
        emit KipuBank.Withdrawal(alice, depositAmount);
        
        // Alice withdraws her funds
        vm.prank(alice);
        kipuBank.withdraw(depositAmount);

        // Assert
        assertEq(kipuBank.getBalanceOf(alice), 0, "Contract balance should be zero");
        assertEq(kipuBank.s_withdrawalCount(), 1, "Withdrawal count should be 1");
        // Check if the ETH returned to her wallet
        assertEq(alice.balance, initialAliceBalance, "Alice's wallet balance should be restored");
    }

    /**
     * @notice Tests if the withdraw function reverts when the amount exceeds the limit.
     */
    function testRevertIfWithdrawalExceedsLimit() public {
        // Arrange
        uint256 depositAmount = 2 ether;
        uint256 withdrawAmount = 1.5 ether; // More than the 1 ether limit
        address alice = makeAddr("alice");
        vm.deal(alice, 10 ether);

        vm.prank(alice);
        kipuBank.deposit{value: depositAmount}();

        // Act & Assert
        vm.expectRevert(
            abi.encodeWithSelector(KipuBank.KipuBank__WithdrawalLimitExceeded.selector, withdrawAmount)
        );
        
        vm.prank(alice);
        kipuBank.withdraw(withdrawAmount);
    }

    /**
     * @notice Tests if the withdraw function reverts when the user has insufficient balance.
     */
    function testRevertIfWithdrawalHasInsufficientBalance() public {
        // Arrange
        uint256 depositAmount = 0.5 ether;
        uint256 withdrawAmount = 1 ether; // More than the user has
        address alice = makeAddr("alice");
        vm.deal(alice, 10 ether);

        vm.prank(alice);
        kipuBank.deposit{value: depositAmount}();

        // Act & Assert
        vm.expectRevert(
            abi.encodeWithSelector(KipuBank.KipuBank__InsufficientBalance.selector, depositAmount, withdrawAmount)
        );
        
        vm.prank(alice);
        kipuBank.withdraw(withdrawAmount);
    }

    /**
     * @notice Tests if the deposit function reverts when the bank cap is exceeded.
     */
    function testRevertIfBankCapExceeded() public {
        // Arrange
        address alice = makeAddr("alice");
        vm.deal(alice, BANK_CAP + 1 ether); // Give Alice more than enough to break the bank

        // Act & Assert
        vm.expectRevert(KipuBank.KipuBank__BankCapExceeded.selector);

        vm.prank(alice);
        kipuBank.deposit{value: BANK_CAP + 1 ether}();
    }
}