# Decentralized Scholarship Fund Smart Contract

This smart contract implements a decentralized scholarship fund using the Clarity language, designed for the Stacks blockchain. It allows users to donate fungible tokens to a scholarship fund, apply for scholarships, and allocate funds to specific categories through earmarked donations.

improvements and new features will be added in subsequent times

## Features

- **Scholarship Donations**: Users can donate to a common scholarship fund.
- **Scholarship Applications**: Students can apply for scholarships by specifying an amount and providing a reason for their request.
- **Approval/Rejection of Applications**: The contract owner can evaluate scholarship applications and either approve or reject them based on the available funds.
- **Earmarked Donations**: Donors can specify a category for their donations, directing funds to specific causes or initiatives.
- **Tracking of Donations and Applications**: The contract tracks total donations, earmarked funds, and application statuses.

## Contract Structure

### Constants

- **Error Codes**: Various constants are defined for error handling, such as invalid amounts, insufficient funds, or unauthorized access.
  - `err-not-owner`, `err-not-found`, `err-already-applied`, `err-insufficient-funds`, `err-application-closed`, `err-arithmetic-error`, `err-invalid-amount`, `err-invalid-reason`, `err-invalid-principal`, `err-invalid-category`.
  
### Data Structures

- **Fungible Token**: `scholarship-token` is the fungible token used for donations and fund transfers.
- **Donors Map**: Tracks total donations made by each donor.
- **Applicants Map**: Tracks scholarship applications, including the amount requested, reason for application, and application status.
- **Earmarked Funds Map**: Tracks total donations earmarked for specific categories.
- **Donor Earmarks Map**: Tracks how much each donor has contributed toward specific categories.

### Variables

- **Total Scholarship Fund**: Tracks the total amount of tokens available in the scholarship fund.
- **Contract Owner**: The address of the contract owner, set during contract deployment.

### Key Functions

#### 1. **Donation Functionality**
- **`donate`**: Allows users to donate fungible tokens to the general scholarship fund.
- **`donate-earmarked`**: Allows users to donate funds to a specific category.

#### 2. **Scholarship Application Functionality**
- **`apply-scholarship`**: Allows students to apply for a scholarship, specifying an amount and a reason.
- **`evaluate-application`**: Allows the contract owner to either approve or reject a student's application.
  - **If approved**: Transfers the requested amount to the student from the scholarship fund.
  - **If rejected**: Updates the status to "rejected" without any transfer.

#### 3. **Read-only Functions**
- **`get-application-status`**: Returns the current status of a student's scholarship application.
- **`get-total-fund`**: Returns the total amount available in the scholarship fund.
- **`get-earmarked-amount`**: Returns the total amount earmarked for a specific category.
- **`get-donor-earmarked-amount`**: Returns the amount a specific donor has earmarked for a given category.

### Private Functions

- **`is-owner`**: Checks if the sender is the contract owner.
- **`safe-add`**: Safely adds two unsigned integers.
- **`validate-amount`**: Ensures the donation or scholarship request amount is valid.
- **`validate-reason`**: Ensures the reason provided for a scholarship application is valid.
- **`validate-principal`**: Ensures that the provided principal is valid.
- **`validate-category`**: Ensures that the category for earmarked donations is valid and within the character limit.

## How to Use

1. **Deploy the Contract**: 
   - Deploy the contract to the Stacks blockchain with the `tx-sender` as the contract owner.
   
2. **Donation**:
   - Call the `donate` function with the `amount` of fungible tokens to contribute to the general scholarship fund.
   - Alternatively, call the `donate-earmarked` function to donate to a specific category by specifying an `amount` and `category`.

3. **Apply for a Scholarship**:
   - Call the `apply-scholarship` function with the `amount-requested` and `reason` for the scholarship.

4. **Evaluate Applications**:
   - The contract owner can approve or reject applications by calling the `evaluate-application` function, specifying the `student` and `approve` boolean (true for approval, false for rejection).

5. **Check Application Status**:
   - Use the `get-application-status` function with the student's principal to retrieve their application status (pending, approved, or rejected).

6. **Query Scholarship Fund**:
   - Use the `get-total-fund` function to check the total amount available in the scholarship fund.
   - Use the `get-earmarked-amount` to check how much has been donated to a specific category.

7. **Track Donor Earmarks**:
   - Use the `get-donor-earmarked-amount` function to check how much a specific donor has earmarked for a particular category.

## Error Handling

The contract uses various error codes for proper error handling. Some of the common errors include:

- **err-not-owner**: Returned if a non-owner tries to perform an owner-only action (like approving applications).
- **err-insufficient-funds**: Raised when the fund does not have enough tokens to approve a scholarship.
- **err-already-applied**: Raised if a student has already applied for a scholarship.
- **err-invalid-amount**: Raised when an invalid donation or application amount is provided.

## License

This project is licensed under the MIT License.