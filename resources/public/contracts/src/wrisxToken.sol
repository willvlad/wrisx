pragma solidity ^0.4.17;

import "./mortal.sol";

contract WrisxToken is Mortal {
    event onRiskExpertRegistered(address indexed expert, string name);
    event onTokensBought(address indexed member, uint tokens);
    event onRiskKnowledgeDeposited(address indexed expert, string indexed uuid);
    event onRiskKnowledgeWithdrawn(address indexed expert, string indexed uuid);
    event onRiskKnowledgePaid(address indexed member, string indexed uuid);
    event onRiskKnowledgeSent(address indexed member, string indexed uuid);
    event onRiskKnowledgeRated(address indexed member, string indexed uuid, uint rate);

    address public owner = msg.sender;

    uint MIN_RATING = 1;
    uint MAX_RATING = 10;

    struct RiskKnowledge {
    address expertAddress;
    uint256 price;
    string password;
    string fileChecksumMD5;
    string fileChecksumSHA1;
    string zipFileChecksumMD5;
    string zipFileChecksumSHA1;
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
    mapping (string => bool) purchases;
    mapping (string => Rating) ratings;
    }

    mapping (address => MemberData) public members;
    mapping (address => RiskExpert) public riskExperts;
    mapping (string => RiskKnowledge) riskKnowledges;

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
    string _uuid,
    string _password,
    string _fileChecksumMD5,
    string _fileChecksumSHA1,
    string _zipFileChecksumMD5,
    string _zipFileChecksumSHA1) public
    returns (string) {
        require (riskExperts[msg.sender].initialized == 1);

        riskKnowledges[_uuid].expertAddress = msg.sender;
        riskKnowledges[_uuid].price = _price;
        riskKnowledges[_uuid].password = _password;
        riskKnowledges[_uuid].fileChecksumMD5 = _fileChecksumMD5;
        riskKnowledges[_uuid].fileChecksumSHA1 = _fileChecksumSHA1;
        riskKnowledges[_uuid].zipFileChecksumMD5 = _zipFileChecksumMD5;
        riskKnowledges[_uuid].zipFileChecksumSHA1 = _zipFileChecksumSHA1;

        riskKnowledges[_uuid].ratingData.totalRating = 0;
        riskKnowledges[_uuid].ratingData.number = 0;

        onRiskKnowledgeDeposited(msg.sender, _uuid);

        return _uuid;
    }

    function withdrawRiskKnowledge(string uuid) public
    returns (bool) {
        require (riskExperts[msg.sender].initialized == 1);

        // TODO

        onRiskKnowledgeWithdrawn(msg.sender, uuid);
    }

    function requestRiskKnowledge(string uuid) public
    returns(string) {
        return strConcat(riskKnowledges[uuid].fileChecksumMD5,
            strConcatWithBytes("|",
                strConcatWithBytes(riskKnowledges[uuid].fileChecksumSHA1,
                    strConcatWithBytes("|",
                        strConcatWithBytes(riskKnowledges[uuid].zipFileChecksumMD5,
                            strConcatToBytes("|", riskKnowledges[uuid].zipFileChecksumSHA1)
                        )
                    )
                )
            )
        );
    }

    function getRiskKnowledgePrice(string uuid) public constant
    returns(uint256) {
        return riskKnowledges[uuid].price;
    }

    function getRiskKnowledgeExpert(string uuid) public
    returns(string) {
        address expertAddress = riskKnowledges[uuid].expertAddress;

        return strConcat(addressToString(expertAddress),
            strConcatToBytes("|", riskExperts[expertAddress].name)
        );
    }

    function payForRiskKnowledge(string uuid) public {
        require(members[msg.sender].balance >= riskKnowledges[uuid].price);

        members[riskKnowledges[uuid].expertAddress].balance += riskKnowledges[uuid].price;
        members[msg.sender].balance -= riskKnowledges[uuid].price;
        members[msg.sender].purchases[uuid] = true;

        onRiskKnowledgePaid(msg.sender, uuid);
    }

    function getRiskKnowledge(string uuid) public
    returns(string) {
        require(members[msg.sender].balance >= riskKnowledges[uuid].price);
        require(members[msg.sender].purchases[uuid] == true);

        onRiskKnowledgeSent(msg.sender, uuid);

        return riskKnowledges[uuid].password;
    }

    function rateRiskKnowledge(string uuid, uint rate) public
    returns(bool) {
        riskKnowledges[uuid].ratingData.totalRating += rate;
        riskKnowledges[uuid].ratingData.number++;

        onRiskKnowledgeRated(msg.sender, uuid, rate);

        return true;
    }

    function getRiskKnowledgeRating(string uuid) public constant
    returns(uint256) {
        return riskKnowledges[uuid].ratingData.totalRating /
        riskKnowledges[uuid].ratingData.number;
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
