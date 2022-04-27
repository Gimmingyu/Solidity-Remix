pragma solidity >=0.4.22 <=0.6.0;
contract BallotV3 {

    struct Voter {                     
        uint weight;
        bool voted;
        uint vote;
    }
    struct Proposal {                  
        uint voteCount;
    }

    address chairperson;
    mapping(address => Voter) voters;  
    Proposal[] proposals;

    enum Phase {Init,Regs, Vote, Done}  
    Phase public state = Phase.Done; 
    
       //modifiers
   modifier validPhase(Phase reqPhase) 
    { require(state == reqPhase); 
      _; 
    } 
    
     
    
    constructor (uint numProposals) public  {
        chairperson = msg.sender;
        voters[chairperson].weight = 2; // weight 2 for testing purposes
        //proposals.length = numProposals; -- before 0.6.0
        for (uint prop = 0; prop < numProposals; prop ++)
            proposals.push(Proposal(0));
        state = Phase.Regs;
    
    }
       
    // 투표 상태 변화는 의장에 의해 순서대로 지워진다. 
    function changeState(Phase x) public {
        if (msg.sender != chairperson) {revert();}
        if (x < state ) revert();
        state = x;
    }
    
    // 함수 헤더에 validPhase 수정자를 사용
    function register(address voter) public validPhase(Phase.Regs) {
        if (msg.sender != chairperson || voters[voter].voted) revert(); 
        voters[voter].weight = 1;
        voters[voter].voted = false;
          
    }

    // 함수 헤더에 validPhase 수정자를 사용
    function vote(uint toProposal) public validPhase(Phase.Vote)  {
       
        Voter memory sender = voters[msg.sender];
        if (sender.voted || toProposal >= proposals.length) return; 
        sender.voted = true;
        sender.vote = toProposal;   
        proposals[toProposal].voteCount += sender.weight;
    }

    // 함수 헤더에 validPhase 수정자를 사용
    function reqWinner() public validPhase(Phase.Done) view returns (uint winningProposal) {
        // 읽기 전용 함수로써, 체인에 Tx를 기록하지 않는다. 
        uint winningVoteCount = 0;
        for (uint prop = 0; prop < proposals.length; prop++) 
            if (proposals[prop].voteCount > winningVoteCount) {
                winningVoteCount = proposals[prop].voteCount;
                winningProposal = prop;
            }
    }
}