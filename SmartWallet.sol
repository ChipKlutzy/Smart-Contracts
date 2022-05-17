//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SmartWallet {
    event OwnerChanged(address indexed oldguy, address indexed newguy);
    event Deposit(uint DepositAmount);

    address public owner;
    mapping(uint => address payable) public AddressIndex;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only Owner is authorised to access this method");
        _; 
    }

    constructor(address[] memory _payees) {
        owner = msg.sender;

        for (uint i; i < _payees.length; i++) {
            address payee = _payees[i];
            
            require(payee != address(0), "This is a zero address");
            AddressIndex[i] = payable(payee);
        }
    }

    receive() external payable {
        emit Deposit(msg.value);
    }
 
    function changeOwner(address _newOwner) external onlyOwner returns (bool) {
        emit OwnerChanged(owner, _newOwner);
        owner = _newOwner;
        return true;
    }

    function MultiTransfer(uint _amount) external onlyOwner {
        uint i;
        while (AddressIndex[i] != address(0)) {
            AddressIndex[i].transfer(_amount);
            i++;
        }
    }

    function getBal() public view returns (uint bal) {
        bal = address(this).balance;
    }

}

//contract address - 0x979A35b57ffb2720065Df96Bfbd35AF1517a601f
