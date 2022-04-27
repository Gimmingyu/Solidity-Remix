pragma solidity >=0.4.22 <=0.6.0;
contract BallotV2 {

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
    // 단계는 오직 0, 1, 2, 3만 가질 수 있고 다른 값은 전부 무효
    Phase public state = Phase.Init;
    
    
    // constructor 는 배포자로서 의장을 설정한다.
    constructor (uint numProposals) public  {
        chairperson = msg.sender;
        voters[chairperson].weight = 2; 
        for (uint prop = 0; prop < numProposals; prop ++)
            proposals.push(Proposal(0));
        
    }
    
    // 상태 변화 함수
    function changeState(Phase x) public {
        // 오직 의장만이 상태를 바꿀 수 있다.
        if (msg.sender != chairperson) {revert();}
        // 상태는 0 1 2 3 순서로 변경할 것이다. 그렇지 않은 경우 되돌린다.
        if (x < state ) revert();
        state = x;
    }
    
    
}