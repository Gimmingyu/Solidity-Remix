pragma solidity ^0.6.0;
contract Airlines {
    address chairperson;
    struct details { // 항공사 회원 구조
        uint escrow;
        uint status;
        uint hashofDetails;
    }

    mapping (address=>details) public balanceDetails; // 항공사 어카운트 페이먼트와 회원 매핑
    mapping (address=>uint) membership;


    // onlyChairperson 규칙을 위한 수정자
    modifier onlyChairperson {
        require (msg.sender == chairperson);
        _;
    }
    // onlyMember 규칙을 위한 수정자 
    modifier onlyMember {
        require (membership[msg.sender] == 1);
        _;
    }

    // 생성자 함수 payable 함수를 위한 msg.sender와 msg.value 사용 
    constructor() public payable {

        chairperson = msg.sender;
        membership[msg.sender] = 1;
        balanceDetails[msg.sender].escrow = msg.value;
    }

    function register() public payable {
        address AirlineA = msg.sender;
        membership[AirlineA] = 1;
        balanceDetails[msg.sender].escrow = msg.value;
    }

    function unregister(address payable AirlineZ) onlyChairperson public {
        membership[AirlineZ] = 0;
        AirlineZ.transfer(balanceDetails[AirlineZ].escrow);
        balanceDetails[AirlineZ].escrow = 0;
    }

    function request (address toAirline, uint hashofDetails) onlyMember
    public {
        if (membership[toAirline]!= 1) {
            revert ();
        }
        balanceDetails[msg.sender].status = 0;
        balanceDetails[msg.sender].hashofDetails = hashofDetails;
    }

    function response (address fromAirline, uint hashofDetails, uint done)
    onlyMember public {
        if (membership[fromAirline] != 1) {
            revert ();
        }
        balanceDetails[msg.sender].status = done;
        balanceDetails[fromAirline].hashofDetails = hashofDetails;
    }

    function settlePayment (address payable toAirline) onlyMember payable public {
        address fromAirline = msg.sender;
        uint amt = msg.value;

        balanceDetails[toAirline].escrow = balanceDetails[toAirline].escrow + amt;
        balanceDetails[fromAirline].escrow = balanceDetails[fromAirline].escrow - amt;

        toAirline.transfer(amt); // 외부 어카운트로 금액을 전송하는 스마트 컨트랙트 어카운트 
    }
}

