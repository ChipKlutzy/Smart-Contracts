//SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract RetirementFunds {

    event Deposit(address indexed guy, uint indexed amount, uint indexed time);
    event WithDraw(uint guyId, uint indexed amount, uint indexed time, bool Matured);

    uint public depositCount;
    uint public penaltySUM;
    address payable public manager;

    struct Accounts {
        uint ID;
        uint balanceOf;
        uint time;
    }

    mapping(address => Accounts) public account;

    modifier onlyManager() {
        require(msg.sender == manager, "Only manager can call this method");
        _;
    }

    constructor() payable {
        require(msg.value >= 2 ether, "Manager should need to do a security deposit of atleast 2 ETH");
        manager = payable(msg.sender);
    }

    receive() external payable {
        emit Deposit(msg.sender, msg.value, block.timestamp);
        depositCount += 1;
        account[msg.sender] = Accounts({ID: depositCount, balanceOf: msg.value, time: block.timestamp});
    }

    function CashOut() external {
        require(account[msg.sender].balanceOf > 0, "Sorry You Cannot Withdraw");

        if(block.timestamp > account[msg.sender].time + 60 seconds) {
            emit WithDraw(account[msg.sender].ID, account[msg.sender].balanceOf, block.timestamp, true);
            payable(msg.sender).transfer(account[msg.sender].balanceOf);
            account[msg.sender].balanceOf = 0;
        }
        else {
            emit WithDraw(account[msg.sender].ID, account[msg.sender].balanceOf * 9/10, block.timestamp, false);
            payable(msg.sender).transfer(account[msg.sender].balanceOf * 9/10);
            penaltySUM += account[msg.sender].balanceOf * 1/10;
            account[msg.sender].balanceOf = 0;
        }
    }

    function collectFees() external onlyManager {
        require(address(this).balance >= 2 ether, "This contract should contain atleast 2 ETH.");
        require(penaltySUM > 0, "No Penalties Accumulated right now. Comeback Later");

        manager.transfer(penaltySUM);
        penaltySUM = 0;
    }

    //Checks and Returns the balanceOf this contract
    function getBal() external view returns (uint) {
        return address(this).balance;
    }

}

