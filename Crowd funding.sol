// SPDX-License-Identifier:MIT
contract CrowdFunding{
    //variables
    address public creator;
    uint256 public goal;
    uint256 public deadline;
    uint256 public totalRaised;
    bool public isWithdrawn;
    bool public isFunded;
    bool public enabledRefund;
    mapping(address => uint) public contributions;

    //Events 
    event ContributionReceived(address contributor, uint amount);
    event GoalReached(uint totalRaised);
    event FundsWithdrawn(address creator, uint amount);
    event RefundIssued(address contributor, uint amount);

    //Functions
    constructor() {
        creator = msg.sender;
    }

    //Contribute funds
    function contributeFunds(uint256 _amount) public {
        require(_amount > 0, "Amount greater than zero");
        contributions[msg.sender] += _amount;
        totalRaised += _amount;
        emit ContributionReceived(msg.sender, _amount);
    }

    //Check Fund Status
    function checkFundStatus() public {
        require(totalRaised >= goal, "Goal amount is not reached");
        isFunded = true;
        emit GoalReached(totalRaised);
    }

    //Withdraw funds
    function withdrawFunds() public payable{
        require(msg.sender == creator, "Invalid user");
        require(totalRaised >= goal && block.timestamp > deadline, "Goal is not reached");
        require(isWithdrawn == false, "Already withdrawn");
        isWithdrawn = true; 
        payable(msg.sender).transfer(address(this).balance);
        emit FundsWithdrawn(msg.sender, totalRaised);
    }

    //Enable refunds
    function enableRefunds() public {
        require(block.timestamp > deadline && totalRaised < goal, "Goal is reached no need to enable refund");
        enabledRefund = true;
    }

    //Claim refund
    function claimRefund() public payable{
        require(block.timestamp > deadline, "Deadline has not passed yet");
        require(totalRaised < goal, "Goal is reached, no need for refunds");
        require(contributions[msg.sender] > 0, "Caller is not a contributor to the project");

        uint256 refundAmount = contributions[msg.sender]; // Store refund amount
        contributions[msg.sender] = 0; // Set to zero before transfer to avoid re-entrancy issues
        payable(msg.sender).transfer(refundAmount); // Transfer the refund amount

        emit RefundIssued(msg.sender, refundAmount); // Emit refund event
    }
    //Get contribution
    function getContribution(address _contributor) public view  returns(uint256) {
        require(contributions[_contributor] > 0, "Caller is not a contributor to the project");
        return contributions[_contributor];
    }
}