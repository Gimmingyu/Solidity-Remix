pragma solidity >=0.4.22 <0.9.0;

contract BlindAuction {

    struct Bid {                   
        bytes32 blindedBid;
        uint deposit;
    }

    // enum으로 상태 표시 
    enum Phase {Init, Bidding, Reveal, Done}  
    Phase public state = Phase.Init; 

	// 의장이자 수혜자 ? 
    address payable beneficiary; //owner  
    mapping(address => Bid) bids;  // 주소당 1회만 입찰 가능 

	// 가장 많은 금액을 bidding한 사람
    address public highestBidder; 
    uint public highestBid = 0;   
    
    mapping(address => uint) depositReturns; // 탈락한 계정 예치금반환
    //modifiers
    modifier validPhase(Phase reqPhase) 
    { require(state == reqPhase); 
      _; 
    } 

   modifier onlyBeneficiary()
   { require(msg.sender == beneficiary); 
      _;
   }

	constructor() {
		// constructor가 수혜자를 설정.
        beneficiary = msg.sender;
        state = Phase.Bidding;
    }

    function changeState(Phase x) public onlyBeneficiary {
        if (x < state ) revert();
        state = x;
    }
    
	// 블라인드 경매 함수
    function bid(bytes32 blindBid) public payable validPhase(Phase.Bidding)
    {
		// bids의 msg.sender의 value를 Bid 구조체를 이용해 넣어둔다.
 		bids[msg.sender] = Bid({
            blindedBid: blindBid,
            deposit: msg.value
        });
    }
    

    function reveal(uint value, bytes32 secret) public validPhase(Phase.Reveal){
        uint refund = 0;
            Bid storage bidToCheck = bids[msg.sender];
            if (bidToCheck.blindedBid == keccak256(abi.encodePacked(value, secret))) {
            refund += bidToCheck.deposit;
            if (bidToCheck.deposit >= value) {
                if (placeBid(msg.sender, value))
                    refund -= value;
            }}
        msg.sender.transfer(refund);
    }

    function placeBid(address bidder, uint value) internal 
            returns (bool success)
    {
        if (value <= highestBid) {
            return false;
        }
        if (highestBidder != address(0)) {
            // Refund the previously highest bidder.
            depositReturns[highestBidder] += highestBid;
        }
        highestBid = value;
        highestBidder = bidder;
        return true;
    }


    // Withdraw a non-winning bid
    function withdraw() public {   
        uint amount = depositReturns[msg.sender];
        require (amount > 0);
        depositReturns[msg.sender] = 0;
        msg.sender.transfer(amount);
        }
    
    
    //End the auction and send the highest bid to the beneficiary.
    function auctionEnd() public  validPhase(Phase.Done) 
    {
        beneficiary.transfer(highestBid);
    }
}

    
    
