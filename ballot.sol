pragma solidity ^0.5.9;

contract Ballot {

    struct voterDetails {
        uint weight;
        bool voted;
        uint8 voteChoice;
    }

    struct proposal {
        address proposalAddr;               //each proposal is a smart contract, and after the vote count, all but the winning one will be deactivated
        uint voteCount;
    }
    
    enum voteStages {Start, Registration, ToVote, VoteComplete}
    voteStages public stage = voteStages.Start;

    address chairperson;
    mapping(address => voterDetails) votersList;
    proposal[] proposals;

    event votingCompleted();

    uint startTime;  

    modifier validStage(voteStages reqdStage)
    { require(stage == reqdStage);
      _;
    }       

    constructor(uint8 _noOfProposals, address[] memory proposalAddress) public {
        chairperson = msg.sender;
        votersList[chairperson].weight = 1;
        proposals.length = _noOfProposals;
        for(uint i = 0; i < proposals.length; i++) {
            proposals[i].proposalAddr = proposalAddress[i];
        }
        stage = voteStages.Registration;
        startTime = now;                                         // Actual scenario: Much better to pass creation time to constructor, compare with blocktimestamp for deadlines i.e 'now'
    }

    function register(address toVoter) public validStage(voteStages.Registration) {
        //if (stage != voteStages.Registration) {return;}                               //removed by adding modifier in the fuction. this way invalid Tx reverted.
        if (msg.sender != chairperson || votersList[toVoter].voted) return;
        votersList[toVoter].weight = 1;
        votersList[toVoter].voted = false;
        if (now > (startTime + 10 seconds)) {stage = voteStages.ToVote; startTime = now;}        
    }

    function vote(uint8 votedProposal) public validStage(voteStages.ToVote) {
        //if(stage != voteStages.ToVote) {return;}
        voterDetails storage sender = votersList[msg.sender];
        if (sender.voted || votedProposal >= proposals.length) return;
        sender.voted = true;
        sender.voteChoice = votedProposal;
        proposals[votedProposal].voteCount += sender.weight;
        if (now > (startTime+ 10 seconds)) {stage = voteStages.VoteComplete; emit votingCompleted();}   //10 sec is placeholder, will be + actual day voting is supossed to end
    }                                                                                                    //Emits the event, which can be listened to in the web/app layer   

    function winningProposal() public view returns (uint8 _winningProposal) {
        if (stage != voteStages.VoteComplete) {return _winningProposal;}        
        uint256 winningVoteCount = 0;                                           //need method to ensure way to inform if there is a tie.
        for (uint8 prop = 0; prop < proposals.length; prop++)
            if (proposals[prop].voteCount > winningVoteCount) {
                winningVoteCount = proposals[prop].voteCount;
                _winningProposal = prop;
            }
        assert (winningVoteCount > 0);
    }

    function activateAndDeactivate(uint8 winner) public {
        if (stage != voteStages.VoteComplete || msg.sender != chairperson) {return;}
       
        for(uint8 i =0; i < proposals.length; i ++) {
            proposalStruct propAd = proposalStruct(proposals[i].proposalAddr);
            if(i == winner) {
                propAd.setStateOfProposal(true);
            }
            else {
                propAd.setStateOfProposal(false);         
                
            }
        }
    
    }
}

contract proposalStruct {
    
    function setStateOfProposal(bool) public {}
    
}