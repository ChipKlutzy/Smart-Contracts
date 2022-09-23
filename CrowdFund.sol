//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Crowdfund {

    event launched(address creater, uint id, uint goal);
    event Pledged(address guy, uint amount, uint id);
    event Unpledged(address guy, uint amount, uint id);
    event Claimed(uint amount, uint time, uint id);
    event Refunded(address guy, uint amount, uint id);

    struct Campaign {
        address creater;
        uint goal;
        uint pledgeAmt;
        uint StartAt;
        uint EndAt;
        bool collected;
    }

    // IERC20 public immutable token;

    uint count;
    
    mapping(uint => Campaign) campaigns;
    mapping(uint => mapping(address => uint)) pledgedFunds;

        // constructor(address _token) {
        //     token = IERC20(_token);
        // }

    function launch(uint _goal, uint _StartAt, uint _EndAt) external {
        require(msg.sender != address(0), "Zero address cannot be the creater");
        require(block.timestamp < _StartAt, "Already Started");
        require(_EndAt > _StartAt, "Invalid timings");

        count += 1;
        campaigns[count] = Campaign({
            creater: msg.sender,
            goal: _goal,
            pledgeAmt: 0,
            StartAt: _StartAt,
            EndAt: _EndAt,
            collected: false
        });

        emit launched(msg.sender, count, _goal);
    }

    function cancel(uint id) external {
        Campaign memory campaign = campaigns[id];
        require(msg.sender == campaign.creater, "Creater only can call this function");
        require(block.timestamp > campaign.StartAt, "Not yet started");
        require(block.timestamp < campaign.EndAt, "Sorry Campaign is ended");

        delete campaigns[id];
    }

    function pledge(uint id) external payable {
        Campaign storage campaign = campaigns[id];
        require(block.timestamp > campaign.StartAt, "Campaign not yet started");
        require(block.timestamp < campaign.EndAt, "Campaign ended");
        require(msg.value != 0, "Pledge amount should not be zero");

        campaign.pledgeAmt += msg.value;
        pledgedFunds[id][msg.sender] += msg.value;

        emit Pledged(msg.sender, msg.value, id);
    }

    function unpledge(uint id) external {
        Campaign storage campaign = campaigns[id];
        require(pledgedFunds[id][msg.sender] > 0, "Not funds to unpledge");
        require(block.timestamp < campaign.EndAt, "Campaign ended");

        uint bal = pledgedFunds[id][msg.sender];
        campaign.pledgeAmt -= bal;
        pledgedFunds[id][msg.sender] = 0;

        payable(msg.sender).transfer(bal);

        emit Unpledged(msg.sender, bal, id);
    }

    function claim(uint id) external {
        Campaign storage campaign = campaigns[id];
        require(msg.sender == campaign.creater, "Only creater can claim funds");
        require(block.timestamp > campaign.EndAt, "This campaign is not yet ended");
        require(campaign.pledgeAmt >= campaign.goal, "Campaign goal not attained");

        uint bal = campaign.pledgeAmt;
        campaign.pledgeAmt = 0;

        payable(msg.sender).transfer(bal);

        emit Claimed(bal, block.timestamp, id);
    }

    function refund(uint id) external {
        Campaign storage campaign = campaigns[id];
        require(block.timestamp < campaign.EndAt, "Campaign ended");

        uint bal = pledgedFunds[id][msg.sender];
        campaign.pledgeAmt -= bal;
        pledgedFunds[id][msg.sender] = 0;

        payable(msg.sender).transfer(bal);

        emit Refunded(msg.sender, bal, id);
    } 

    
}
