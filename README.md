# KipuBank Smart Contract Project

![Solidity](https://img.shields.io/badge/Solidity-%23363636.svg?style=for-the-badge&logo=solidity&logoColor=white)
![Foundry](https://img.shields.io/badge/Foundry-EFEFEF?style=for-the-badge&logo=foundry&logoColor=black)

## Description

KipuBank is a smart contract built on the Ethereum blockchain as part of a Web3 developer assessment. This project demonstrates fundamental Solidity concepts, security best practices, and a professional development workflow using Foundry.

The contract allows users to:
-   Deposit native ETH into a personal vault.
-   Withdraw ETH from their vault, up to a fixed, per-transaction limit.
-   Operate within a global deposit cap for the entire bank.

This project emphasizes security, readability, and clear documentation, adhering to the "Checks-Effects-Interactions" pattern and using custom errors and modifiers.

---

## Project Structure

This project uses the Foundry framework. The main contract is located in the `/contracts` directory.

-   `/contracts`: Contains the `KipuBank.sol` smart contract.
-   `/test`: Contains the complete test suite (`KipuBank.t.sol`).
-   `/script`: Contains the deployment script (`DeployKipuBank.s.sol`).

---

## Getting Started

To get a local copy up and running, follow these simple steps.

### Prerequisites

You will need the following tools installed on your machine:
-   [Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
-   [Foundry (Forge & Cast)](https://book.getfoundry.sh/getting-started/installation)

### Installation & Setup

1.  **Clone the repository:**
    ```sh
    git clone [https://github.com/](https://github.com/)[SEU_USUARIO_GITHUB]/[NOME_DO_REPOSITORIO].git
    cd [NOME_DO_REPOSITORIO]
    ```

2.  **Build the project:**
    This command will compile the smart contracts.
    ```sh
    forge build
    ```

3.  **Run the tests:**
    This command will run the entire test suite located in the `/test` folder.
    ```sh
    forge test -vv
    ```

---

## Deployment

The contract is designed to be deployed on a testnet (e.g., Sepolia).

1.  **Set up your environment:**
    Create a `.env` file in the root directory and add the following variables:
    ```
    export SEPOLIA_RPC_URL="YOUR_ALCHEMY_OR_INFURA_RPC_URL"
    export PRIVATE_KEY="0xYOUR_WALLET_PRIVATE_KEY"
    export ETHERSCAN_API_KEY="YOUR_ETHERSCAN_API_KEY"

    # Constructor Arguments (in wei)
    export BANK_CAP=100000000000000000000
    export WITHDRAWAL_LIMIT=1000000000000000000
    ```

2.  **Run the deployment script:**
    Load the environment variables and run the deployment script.
    ```sh
    source .env
    forge script script/DeployKipuBank.s.sol:DeployKipuBank --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY --broadcast --verify -vvvv
    ```

---

## How to Interact with the Contract

The KipuBank contract has the following core functions:

-   `deposit()`: (Payable) Allows any user to deposit ETH. Reverts if the amount is zero or if the bank cap is exceeded.
-   `withdraw(uint256 _amount)`: Allows a user to withdraw ETH from their balance. Reverts if the amount is zero, exceeds the withdrawal limit, or if the user has insufficient funds.
-   `getBalanceOf(address _user)`: (View) Returns the current ETH balance of any specified user address within the contract.
-   `i_withdrawalLimit`: (Public View) Shows the immutable withdrawal limit per transaction.
-   `i_bankCap`: (Public View) Shows the immutable total bank cap.

---


## Author

* **Heitor Valim**
* **GitHub:** `https://github.com/heitorvalim7`