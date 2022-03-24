pragma solidity ^0.5.9;

contract ProposalA {

    
    string proposalName;
    uint8 proposalNumber;
    bool state;             //Accept or Reject
    bool votingComplete;
    string proposalDetails;       
    address chairperson;

     constructor(string memory pName, string memory pDetails, uint8 pNumber) public {
         chairperson = msg.sender;
        proposalName = pName;
        proposalDetails = pDetails;
        proposalNumber = pNumber;
        votingComplete = false;
    }

    function getStateOfProposal () public view returns (string memory stateofProp)  {
        if(!votingComplete) {
            return "Voting Incomplete";
        }
        else {
            if(state) {
                return "Accept";
            }
            else {
                return "Rejected";
            }
        }
    }

    function setStateOfProposal(bool pState) public {
        if (msg.sender != chairperson || votingComplete == true) return;
        state = pState;
        votingComplete = true;
    }
}