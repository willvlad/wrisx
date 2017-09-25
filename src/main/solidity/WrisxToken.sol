pragma solidity ^0.4.10;

contract owned {
    address public owner;

    function owned() {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) onlyOwner {
        owner = newOwner;
    }
}

contract WrisxToken is owned {

    struct RiskKnowledge {
    address expertAddress;
    uint256 price;
    string title;
    string keyWord;
    string description;
    string link;
    uint256 hash;
    string password;
    Rating rating;
    bool withdrawn;
    }

    struct Rating {
    uint totalRating;
    uint number;
    uint initialized;
    }

    mapping (address => uint256) public balanceOf;
    mapping (address => Rating) public riskExpertRatings;
    mapping (uint => Rating) public riskKnowledgeRatings;
    mapping (uint => address) public riskKnowledgeAddresses;
    mapping (uint => uint256) public riskKnowledgePrices;
    mapping (uint => string) public riskKnowledgeTitles;
    mapping (uint => string) public riskKnowledgeKeyWords;
    mapping (uint => string) public riskKnowledgeDescriptions;
    mapping (uint => string) public riskKnowledgeLinks;
    mapping (uint => uint256) public riskKnowledgeHashes;
    mapping (uint => string) public riskKnowledgePasswords;

    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;
    uint public riskKnowledgeCount;

    function WrisxToken(
    string _name,
    string _symbol,
    uint8 _decimals,
    uint256 _totalSupply) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        totalSupply = _totalSupply;
        balanceOf[msg.sender] = _totalSupply;
        riskKnowledgeCount = 0;
    }

    function getBalance(address member) constant returns(uint256 balance) {
        return this.balanceOf(member);
    }

    function registerRiskExpert() returns (bool success) {
        require (riskExpertRatings[msg.sender].initialized == 0);

        riskExpertRatings[msg.sender].initialized = 1;

        return true;
    }

    function getExpertInitialized(address expert) constant returns(uint init) {
        return riskExpertRatings[expert].initialized;
    }

    function getExpertTotalRating(address expert) constant returns(uint totalRating) {
        return riskExpertRatings[expert].totalRating;
    }

    function depositRiskKnowledge(
    uint256 _price,
    string _title,
    string _keyWord,
    string _description,
    string _link,
    uint256 _hash,
    string _password)
    returns (bool success) {
        require (riskExpertRatings[msg.sender].initialized == 1);

        riskKnowledgeAddresses[riskKnowledgeCount] = msg.sender;
        riskKnowledgePrices[riskKnowledgeCount] = _price;
        riskKnowledgeTitles[riskKnowledgeCount] = _title;
        riskKnowledgeKeyWords[riskKnowledgeCount] = _keyWord;
        riskKnowledgeDescriptions[riskKnowledgeCount] = _description;
        riskKnowledgeLinks[riskKnowledgeCount] = _link;
        riskKnowledgeHashes[riskKnowledgeCount] = _hash;
        riskKnowledgePasswords[riskKnowledgeCount] = _password;
        riskKnowledgeCount++;
//
//        riskKnowledgeRatings[ind].initialized == 1;
//        riskKnowledgeRatings[ind].totalRating == 0;
//        riskKnowledgeRatings[ind].number == 0;

        return true;
    }

    function getRiskKnowledgeTitle(uint ind) constant returns(string title) {
        return riskKnowledgeTitles[ind];
    }

    function getRiskKnowledgeCount() constant returns(uint c) {
        return riskKnowledgeCount;
    }
}
