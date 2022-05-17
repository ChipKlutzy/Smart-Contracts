//SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Escrow {
    enum State {ConfirmOrder, AwaitingPayment, AwaitingDelivery, Completed}
    State public currState;

    uint price;
    address payable buyer;
    address payable seller;

    modifier onlyBuyer() {
        require(msg.sender == buyer, "Sorry this method can only called by buyer");
        _;
    }

    modifier onlySeller() {
        require(msg.sender == seller, "Sorry this method can only called by seller");
        _;
    }
 
    constructor (uint _price, address payable _buyer, address payable _seller) {
        price = _price;
        buyer = _buyer;
        seller = _seller;
        currState = State.ConfirmOrder;
    }

    function ReceiveOrder() external payable onlySeller {
        require(currState == State.ConfirmOrder, "Invalid Escrow State !!!");
        require(msg.value == price, "Lock enough funds in the escrow !");
        currState = State.AwaitingPayment;
    }

    function Payment() external payable onlyBuyer {
        require(currState == State.AwaitingPayment, "Invalid Escrow State !!!");
        require(msg.value == 2 * price, "Lock enough funds in the escrow !");
        currState = State.AwaitingDelivery;
    }

    function Release() external onlyBuyer {
        require(currState == State.AwaitingDelivery, "Invalid Escrow State !!!");
        currState = State.Completed;
        buyer.transfer(price);
        seller.transfer(2 * price);
    }

    function checkBal() public view returns (uint) {
        return address(this).balance;
    }

 }

 // Constructor Arguments
 // price - 1000000000000000000
 // buyer - 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2
 // seller - 0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db
