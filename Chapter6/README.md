# Blockchain In Action 6장

---

> 블록체인 인 액션 책을 읽고 공부한 내용을 기록한 글 입니다. 글에 나와있는 내용과 사진은 모두 블록체인 인 액션에 포함된 내용 혹은 이를 정리한 것 입니다. 문제가 될 시 삭제하겠습니다.

---

<br />

블록체인 애플리케이션에는 온체인 데이터라는 개념이 있다.

Dapp에서 사용하는 데이터는 블록체인 인프라에 저장하고

다른 데이터는 데이터베이스나 파일에 저장한다.

여기서 블록체인 인프라에 저장되는 데이터가 온체인, 나머지가 오프체인 데이터이다.

블록체인에서는 다음과 같은 데이터를 노드에 저장한다. (온체인)

-   실행하고 컨펌받은 트랜잭션
-   스마트 컨트랙트 함수의 실행 결과
-   상태 변화 ( storage 변수값에 일어난 변화)
-   발생시킨 이벤트 로그

이러한 데이터를 저장한 후, 블록체인 프로토콜에서 설정한 대로 다른 첨여 노드로 전파한다.

블록체인 기반 시스템을 이용한 비즈니스 시스템에서는 대부분의 경우, 위 두 가지 경우를 모두 다루어야 한다.

<br />

주어진 탈중앙화 시나리오에서 Dapp을 설계할 때 가장 중요한 임무는 다음의 두 가지를 식별(구분)하는 것이다.

-   통합 시스템에서 블록체인 외적인 파트가 담당하는 부분
-   블록체인 애플리케이션이 담당하는 부분

이 때, Dapp 설계 및 개발을 담당하는 사람은 온체인과 오프체인에 어떤 데이터들을 저장할 지 결정해야 한다.

지난 포스팅에서 소개한 ASK 유스 케이스와 블라인드 경매 유스케이스를 통해 온체인 데이터와 오프체인 데이터를 나누는 방법을 이해해보자.

---

## 온체인 데이터의 요소

온체인 데이터의 요소들은 다음과 같다.

1. 블록체인 헤더 
   - 블록의 속성을 정의
2. 트랜잭션 
   - 블록에 저장된 Tx의 내용을 저장 
3. 리시트 
   - 블록에 기록된 Tx의 실행 결과를 저장 
4. 글로벌 스테이트(State Tree)
   - 모든 블록체인상의 스마트 컨트랙트와 다른 일반 어카운트의 현재 state 및 데이터 저장

이러한 아이템들의 해시가 현재 블록의 해시가 된다. 

현재 블록의 해시는 체인에 추가되는 다음 블록 해시를 구성하는 부분으로 저장되며 체인 링크를 형성한다.

여기서 알아야 할 점은, 리시트 트리, Tx 트리 블록헤더는 블록 단위(per-block) 데이터 구조,

State Tree는 블록체인단위(per blockchain) 구조라는 것이다.

State Tree는 블록체인에 어떤 것이 어떻게 일어났는지에 대한 히스토리 전체를 기록한다. 

이러한 요소들의 특징과 속성을 잘 알아둬야 온체인 데이터를 잘 통제할 수 있고, 

그것은 곧 블록체인의 견고성과 보안성을 잘 확보할 수 있다는 뜻이 된다. 

---

## 온체인 이벤트 데이터 

솔리디티에서는 이벤트를 정의하고 발생시키는 기능을 제공하는데, 이벤트는 파라미터를 가질 수도 아닐 수도 있다. 

이벤트는 온체인의 리시트 트리에 로그인되는데, 그 이름으로 액세스할 수 있다. 

Example
```javascript
// 스마트 컨트랙트에서 타입과 변수 선언 바로 뒤에 이벤트를 정의해준다. 
event NameOfEvent (parameters);

// 다수의 파라미터를 사용하는 예시
event AuctionEnded(address winner, uint highestBid);

// 이벤트를 발생시키는 예시
emit AuctionEnded(address winner, uint highestB);

// 파라미터가 없는 이벤트 
event BiddingStarted();
event RevealStarted();

emit BiddingStarted();
emit RevealStarted();
```

<br />

이벤트는 블록의 리시트 트리에 기록하는 전형적인 온체인 데이터이다. 

이벤트 로그는 경매 케이스처럼 거의 리얼타임 수준의 응답에도 사용할 수 있지만

오프라인에서 인덱싱해서 조회하거나 온체인 데이터를 분석할 때도 사용한다. 

---

### 이벤트를 가진 블라인드 경매 코드 example 

```javascript
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

```

이전과 다른 점은 changeState() 함수 대신 advancePhase() 함수를 사용한다는 것이다. 

advancePhase() 함수는 Init, Bidding, Reveal, Done 단계를 거치면 다음 경매를 위해 

Init으로 Phase를 재설정해준다. 또한 경매 시작과 끝을 알리는 이벤트를 발생시킨다. 