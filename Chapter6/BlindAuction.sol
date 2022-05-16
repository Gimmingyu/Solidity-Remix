pragma solidity >=0.4.22 <=0.6.0;

contract BlindAuction {
    struct Bid {
        bytes32 blindedBid;
        uint256 deposit;
    }

    // 단계는 오직 수혜자만이 설정할 수 있다.
    // Init - 0; Bidding - 1; Reveal - 2; Done - 3
    enum Phase {
        Init,
        Bidding,
        Reveal,
        Done
    }
    // Owner
    address payable public beneficiary;
    // Keep track of the highest bid,bidder
    address public highestBidder;
    uint256 public highestBid = 0;
    // Only one bid allowed per address
    mapping(address => Bid) public bids;
    mapping(address => uint256) pendingReturns;

    Phase public currentPhase = Phase.Init;
    // Events Definitions
    event AuctionEnded(address winner, uint256 highestBid);
    event BiddingStarted();
    event RevealStarted();
    event AuctionInit();
    // Modifiers
    modifier validPhase(Phase phase) {
        require(currentPhase == phase, "phaseError");
        _;
    }
    modifier onlyBeneficiary() {
        require(msg.sender == beneficiary, "onlyBeneficiary");
        _;
    }

    constructor() public {
        beneficiary = msg.sender;
        // advancePhase();
    }

    function advancePhase() public onlyBeneficiary {
        // If already in done phase, reset to init phase
        if (currentPhase == Phase.Done) {
            currentPhase = Phase.Init;
        } else {
            // else, increment the phase
            // Conversion to uint needed as enums are internally uints
            uint256 nextPhase = uint256(currentPhase) + 1;
            currentPhase = Phase(nextPhase);
        }

        // Emit appropriate events for the new phase
        if (currentPhase == Phase.Reveal) emit RevealStarted();
        if (currentPhase == Phase.Bidding) emit BiddingStarted();
        if (currentPhase == Phase.Init) emit AuctionInit();
    }

    function bid(bytes32 blindBid) public payable validPhase(Phase.Bidding) {
        require(msg.sender != beneficiary, "beneficiaryBid"); // Beneficiary should not be allowed to place bids
        bids[msg.sender] = Bid({blindedBid: blindBid, deposit: msg.value});
    }

    function reveal(uint256 value, bytes32 secret)
        public
        validPhase(Phase.Reveal)
    {
        require(msg.sender != beneficiary, "beneficiaryReveal");
        uint256 refund = 0;
        Bid storage bidToCheck = bids[msg.sender];

        if (
            bidToCheck.blindedBid == keccak256(abi.encodePacked(value, secret))
        ) {
            refund += bidToCheck.deposit;
            if (bidToCheck.deposit >= value * 1000000000000000000) {
                if (placeBid(msg.sender, value * 1000000000000000000))
                    refund -= value * 1000000000000000000;
            }
        }
        msg.sender.transfer(refund);
    }

    // This is an "internal" function which means that it
    // can only be called from the contract itself (or from
    // derived contracts).
    function placeBid(address bidder, uint256 value)
        internal
        returns (bool success)
    {
        if (value <= highestBid) {
            return false;
        }
        if (highestBidder != address(0)) {
            // Refund the previously highest bidder.
            pendingReturns[highestBidder] += highestBid;
        }

        highestBid = value;
        highestBidder = bidder;
        return true;
    }

    // Withdraw a non-winning bid
    function withdraw() public {
        uint256 amount = pendingReturns[msg.sender];
        if (amount > 0) {
            pendingReturns[msg.sender] = 0;
            msg.sender.transfer(amount);
        }
    }

    // Send the highest bid to the beneficiary and
    // end the auction
    function auctionEnd() public validPhase(Phase.Done) {
        if (address(this).balance >= highestBid) {
            beneficiary.transfer(highestBid);
        }
        emit AuctionEnded(highestBidder, highestBid);
    }

    function closeAuction() public onlyBeneficiary {
        selfdestruct(beneficiary);
    }
}
