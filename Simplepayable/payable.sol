// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Payable {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "only owners can withdraw");
        _;
    }

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }

    receive() external payable {}

    fallback() external payable {}

    function withdrawAll() external onlyOwner {
        (bool success, ) = payable(owner).call{value: address(this).balance}(
            ""
        );

        require(success == true, "an error occurred while withdrawing");
    }

    function withdrawSome(address reciepent, uint256 amount)
        external
        onlyOwner
    {
        require(
            address(this).balance >= amount,
            "insufficient balance to withdraw"
        );
        require(amount != 0, "please your withdraw amount cannot be 0");

        // reciepent.transfer(amount);

        (bool success, ) = payable(reciepent).call{value: amount * 1 ether}("");

        require(success == true, "an error occurred while withdrawing");
    }
}
