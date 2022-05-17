//SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

contract SpecialAuction {
    uint floorPrice;
    uint currenthighestBid;
    address payable public auctioner;
    address payable highestBidder;
    enum AuctionState {OPENED, CLOSED}
    AuctionState AS;

    constructor (uint _floorPrice) {
        AS = AuctionState.OPENED;
        floorPrice = _floorPrice;// Floor Price
        currenthighestBid = 0;// Set to 0 since no one asked
        auctioner = payable(msg.sender);// The deployer becomes the auctioner
    }

    function bid() external payable {
        require(AS == AuctionState.OPENED, "Auction Closed!!!");
        require(msg.value >= floorPrice && msg.value > currenthighestBid, "Place Higher bid");
        require(msg.sender != address(0));
        if(currenthighestBid == 0) {
            highestBidder = payable(msg.sender);
            currenthighestBid = msg.value;
        }
        else {
            Refund(highestBidder, currenthighestBid);
            highestBidder = payable(msg.sender);
            currenthighestBid = msg.value;
        }
    }

    function Refund(address payable prevhighBidder, uint LastBid) internal {
        prevhighBidder.transfer(LastBid);
    }

    function endAuction() external returns(uint salePrice) {
        require(msg.sender == auctioner, "You are not the administrator of this auction");
        salePrice = currenthighestBid;
        AS = AuctionState.CLOSED;
        auctioner.transfer(address(this).balance);
        return salePrice;
    }
}

// This Contract is deployed on Kovan Test Network By:
// 0xd67b65fdd20d871A732C7D9cC704D9C2f71aB4F0
// And Contract's Address is:
// 0x02E86221C5640B67Cfd3959f6940b22A382D6F31
