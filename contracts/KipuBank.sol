// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title KipuBank
 * @author heitorvalim7
 * @notice this contracts allows to receive and send ETH securely
 */
contract KipuBank {
    // =================================================================
    // State Variables
    // =================================================================

    /**
     * @notice The maximum amount a user can withdraw in a single transaction.
    */
    uint256 public immutable iWITHDRAWAL_LIMIT; 

    /**
     * @notice The maximum amount of ETH this entire contract can hold.
     */
    uint256 public immutable iBANK_CAP; 

    /**
     * @notice Mapping from user address to their ETH balance.
     */
    mapping(address => uint256) private s_balances; // works like an array, for each address, there is an specific amount

    /**
     * @notice Total number of successful deposits.
     */
    uint256 public s_depositCount;

    /**
     * @notice Total number of successful withdrawals.
     */
    uint256 public s_withdrawalCount;
    
    // =================================================================
    // Errors
    // =================================================================
    
    // it explains what the system should do if something happens, but doesnt do anything itself

    error KipuBank__ZeroAmountNotAllowed();
    error KipuBank__BankCapExceeded();
    error KipuBank__WithdrawalLimitExceeded(uint256 requestedAmount);
    error KipuBank__InsufficientBalance(uint256 userBalance, uint256 requestedAmount);
    error KipuBank__TransferFailed();

    // =================================================================
    // Events
    // =================================================================
    
    event Deposit(address indexed user, uint256 amount);
    event Withdrawal(address indexed user, uint256 amount);

    // =================================================================
    // Modifiers
    // =================================================================
    
    modifier nonZeroAmount(uint256 _amount) {
    if (_amount == 0) {
        revert KipuBank__ZeroAmountNotAllowed();
    }
    _; 
    }

    // =================================================================
    // Constructor
    // =================================================================
    
    constructor(uint256 bankCap, uint256 withdrawalLimit){ //parameters, works like a function
        iBANK_CAP = bankCap;                               //gets the bankcap
        iWITHDRAWAL_LIMIT = withdrawalLimit;               //gets the withdrawal limit
        
    }

    // =================================================================
    // External Functions
    // =================================================================

    /**
     * @notice Allows a user to deposit ETH.
     * @dev The sent value (`msg.value`) is used as the deposit amount.
     */
    function deposit() external payable nonZeroAmount(msg.value){ //the function can only be called outside of the contract and can receive ETH
        
        //verifying the conditions firts
        
        _checkDepositConditions();

        //effects of the transaction

        s_balances[msg.sender] += msg.value; //adds the value deposited by the person to their account
        _incrementDepositCount(); // increments the number of deposits made

        //interaction
        emit Deposit(msg.sender, msg.value);
    }

    /**
     * @notice Allows a user to withdraw their ETH balance.
     * @param _amount The amount of ETH to withdraw.
     */
    function withdraw(uint256 _amount) external nonZeroAmount(_amount) {

        uint256 userBalance = s_balances[msg.sender];

        //again, verifying the condtions first

        _checkWithdrawalConditions(_amount, userBalance);

        //effects of the function

        s_balances[msg.sender] -= _amount;
        _incrementWithdrawalCount();

        //interactions

        (bool success, ) = msg.sender.call{value: _amount}(""); //leaving a space after the "," bc the code doesnt need the bytes memory data so we just ignore it
            if (!success) {
                revert KipuBank__TransferFailed();
            }

        emit Withdrawal(msg.sender, _amount);
    }

    // =================================================================
    // View Functions
    // =================================================================

    /**
     * @notice Gets the ETH balance of a specific user.
     * @param _user The address of the user.
     * @return The user's balance in wei.
     */
    function getBalanceOf(address _user) external view returns (uint256){
        return s_balances[_user];
    }

    // =================================================================
    // Private Functions
    // =================================================================

    function _incrementDepositCount() private {
        s_depositCount++;
    }

    function _incrementWithdrawalCount() private {
        s_withdrawalCount++;
    }

    function _checkWithdrawalConditions(uint256 _amount, uint256 _userBalance) private view {
    
        if (_amount > iWITHDRAWAL_LIMIT) {
            revert KipuBank__WithdrawalLimitExceeded(_amount);
        }
        if (_userBalance < _amount) {
            revert KipuBank__InsufficientBalance(_userBalance, _amount);
        }
    }

    function _checkDepositConditions() private view {
        if (address(this).balance > iBANK_CAP) { 
            revert KipuBank__BankCapExceeded();
        }
    }
}