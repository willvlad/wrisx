pragma solidity ^0.4.17;

import "./mortal.sol";

contract WrisxToken is Mortal {
    event onRiskExpertRegistered(address indexed expert, string name);
    event onTokensBought(address indexed member, uint tokens);
    event onRiskKnowledgeDeposited(address indexed expert, uint indexed ind);
    event onRiskKnowledgeWithdrawn(address indexed expert, uint indexed ind);
    event onRiskKnowledgePaid(address indexed member, uint indexed ind);
    event onRiskKnowledgeSent(address indexed member, uint indexed ind);
    event onRiskKnowledgeRated(address indexed member, uint indexed ind, uint rate);

    address public owner = msg.sender;

    uint MIN_RATING = 1;
    uint MAX_RATING = 10;

    struct RiskKnowledge {
    address expertAddress;
    uint256 price;
    string title;
    string keyWords;
    string description;
    string link;
    string hash;
    string password;
    RatingData ratingData;
    bool withdrawn;
    uint numberOfPurchases;
    }

    struct RiskExpert {
    string name;
    mapping (uint => RatingData) riskKnowledgeRatings;
    uint totalRating;
    uint number;
    uint initialized;
    }

    struct RatingData {
    uint totalRating;
    uint number;
    mapping (address => Rating) ratings;
    }

    struct Rating {
    uint rating;
    string comment;
    bool done;
    }

    struct RiskKnowledgePurchase {
    uint totalRating;
    uint number;
    }

    struct MemberData {
    uint256 balance;
    mapping (uint => bool) purchases;
    mapping (uint => Rating) ratings;
    }

    mapping (address => MemberData) public members;
    mapping (address => RiskExpert) public riskExperts;
    mapping (uint => RiskKnowledge) riskKnowledgeArray;

    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;
    uint8 public tokenPriceEther;

    uint public riskKnowledgeCount;

    function WrisxToken(
    string _name,
    string _symbol,
    uint8 _decimals,
    uint256 _totalSupply,
    uint8 _tokenPriceEther) public {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        totalSupply = _totalSupply;
        members[msg.sender].balance = _totalSupply;
        tokenPriceEther = _tokenPriceEther;

        riskKnowledgeCount = 0;
    }

    function () public payable {

    }

    function buyTokens() public payable {
        uint numberOfTokens = msg.value / tokenPriceEther;

        require (members[owner].balance >= numberOfTokens);

        members[msg.sender].balance += numberOfTokens;
        members[owner].balance -= numberOfTokens;

        onTokensBought(msg.sender, numberOfTokens);
    }

    function getBalance() public constant returns(uint256 balance) {
        return getMemberBalance(msg.sender);
    }

    function getMemberBalance(address member) public constant returns(uint256 balance) {
        return members[member].balance;
    }

    function registerRiskExpert(string _name) public returns (bool success) {
        require (riskExperts[msg.sender].initialized == 0);

        riskExperts[msg.sender].initialized = 1;
        riskExperts[msg.sender].name = _name;

        onRiskExpertRegistered(msg.sender, _name);

        return true;
    }

    function getExpertInitialized(address expertAddress) public constant returns(uint init) {
        return riskExperts[expertAddress].initialized;
    }

    function getExpertTotalRating(address expertAddress) public constant returns(uint totalRating) {
        require (riskExperts[expertAddress].initialized == 1);

        return riskExperts[expertAddress].totalRating;
    }

    function getExpertRating(address expertAddress) public constant
    returns(uint256) {
        require (riskExperts[expertAddress].initialized == 1);

        return riskExperts[expertAddress].totalRating / riskExperts[expertAddress].number;
    }

    function depositRiskKnowledge(
    uint256 _price,
    string _title,
    string _keyWords,
    string _description,
    string _link,
    string _hash,
    string _password) public
    returns (uint) {
        require (riskExperts[msg.sender].initialized == 1);

        riskKnowledgeArray[riskKnowledgeCount].expertAddress = msg.sender;
        riskKnowledgeArray[riskKnowledgeCount].price = _price;
        riskKnowledgeArray[riskKnowledgeCount].title = _title;
        riskKnowledgeArray[riskKnowledgeCount].keyWords = _keyWords;
        riskKnowledgeArray[riskKnowledgeCount].description = _description;
        riskKnowledgeArray[riskKnowledgeCount].link = _link;
        riskKnowledgeArray[riskKnowledgeCount].hash = _hash;
        riskKnowledgeArray[riskKnowledgeCount].password = _password;

        riskKnowledgeArray[riskKnowledgeCount].ratingData.totalRating = 0;
        riskKnowledgeArray[riskKnowledgeCount].ratingData.number = 0;

        uint oldRiskKnowledgeCount = riskKnowledgeCount;

        riskKnowledgeCount++;

        onRiskKnowledgeDeposited(msg.sender, oldRiskKnowledgeCount);

        return oldRiskKnowledgeCount;
    }

    function withdrawRiskKnowledge(uint ind) public
    returns (bool) {
        require (riskExperts[msg.sender].initialized == 1);

        onRiskKnowledgeWithdrawn(msg.sender, ind);
    }

    function getRiskKnowledgeTitle(uint ind) public constant returns(string title) {
        return riskKnowledgeArray[ind].title;
    }

    function getRiskKnowledgeCount() public constant returns(uint c) {
        return riskKnowledgeCount;
    }

    function requestRiskKnowledge(uint ind) public
    returns(string) {
        require(ind < riskKnowledgeCount);

        return strConcat(riskKnowledgeArray[ind].title,
            strConcatWithBytes("|",
                strConcatWithBytes(riskKnowledgeArray[ind].description,
                    strConcatWithBytes("|",
                        strConcatWithBytes(riskKnowledgeArray[ind].link,
                            strConcatToBytes("|", riskKnowledgeArray[ind].hash)
                        )
                    )
                )
            )
        );
    }

    function getRiskKnowledgePrice(uint ind) public constant
    returns(uint256) {
        require(ind < riskKnowledgeCount);

        return riskKnowledgeArray[ind].price;
    }

    function getRiskKnowledgeExpert(uint ind) public
    returns(string) {
        require(ind < riskKnowledgeCount);

        address expertAddress = riskKnowledgeArray[ind].expertAddress;

        return strConcat(addressToString(expertAddress),
            strConcatToBytes("|", riskExperts[expertAddress].name)
        );
    }

    function payForRiskKnowledge(uint ind) public {
        require(ind < riskKnowledgeCount);
        require(members[msg.sender].balance >= riskKnowledgeArray[ind].price);

        members[riskKnowledgeArray[ind].expertAddress].balance += riskKnowledgeArray[ind].price;
        members[msg.sender].balance -= riskKnowledgeArray[ind].price;
        members[msg.sender].purchases[ind] = true;

        onRiskKnowledgePaid(msg.sender, ind);
    }

    function getRiskKnowledge(uint ind) public
    returns(string) {
        require(ind < riskKnowledgeCount);
        require(members[msg.sender].balance >= riskKnowledgeArray[ind].price);
        require(members[msg.sender].purchases[ind] == true);

        onRiskKnowledgeSent(msg.sender, ind);

        return strConcat(riskKnowledgeArray[ind].title,
            strConcatWithBytes("|",
                strConcatWithBytes(riskKnowledgeArray[ind].link,
                    strConcatWithBytes("|",
                        strConcatWithBytes(riskKnowledgeArray[ind].hash,
                            strConcatToBytes("|", riskKnowledgeArray[ind].password)
                        )
                    )
                )
            )
        );
    }

    function rateRiskKnowledge(uint ind, uint rate) public
    returns(bool) {
        require(ind < riskKnowledgeCount);

        riskKnowledgeArray[ind].ratingData.totalRating += rate;
        riskKnowledgeArray[ind].ratingData.number++;

        onRiskKnowledgeRated(msg.sender, ind, rate);

        return true;
    }

    function getRiskKnowledgeRating(uint ind) public constant
    returns(uint256) {
        require(ind < riskKnowledgeCount);

        return riskKnowledgeArray[ind].ratingData.totalRating /
                        riskKnowledgeArray[ind].ratingData.number;
    }

    function strConcat(string _a, bytes _bb) internal
    returns (string) {
        bytes memory _ba = bytes(_a);
        string memory ab = new string(_ba.length + _bb.length);
        bytes memory bab = bytes(ab);
        uint k = 0;
        for (uint i = 0; i < _ba.length; i++) bab[k++] = _ba[i];
        for (i = 0; i < _bb.length; i++) bab[k++] = _bb[i];

        return string(bab);
    }

    function strConcatToBytes(string _a, string _b) internal
    returns (bytes) {
        bytes memory _ba = bytes(_a);
        bytes memory _bb = bytes(_b);
        string memory ab = new string(_ba.length + _bb.length);
        bytes memory bab = bytes(ab);
        uint k = 0;
        for (uint i = 0; i < _ba.length; i++) bab[k++] = _ba[i];
        for (i = 0; i < _bb.length; i++) bab[k++] = _bb[i];

        return bab;
    }

    function strConcatWithBytes(string _a, bytes _bb) internal
    returns (bytes) {
        bytes memory _ba = bytes(_a);
        string memory ab = new string(_ba.length + _bb.length);
        bytes memory bab = bytes(ab);
        uint k = 0;
        for (uint i = 0; i < _ba.length; i++) bab[k++] = _ba[i];
        for (i = 0; i < _bb.length; i++) bab[k++] = _bb[i];

        return bab;
    }

    function addressToString(address x) internal returns (string) {
        bytes memory b = new bytes(20);
        for (uint i = 0; i < 20; i++)
        b[i] = byte(uint8(uint(x) / (2**(8*(19 - i)))));
        return string(b);
    }

}
