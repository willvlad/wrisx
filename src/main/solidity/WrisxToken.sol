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
    uint8 public tokenPriceEther;

    uint public riskKnowledgeCount;

    function WrisxToken(
    string _name,
    string _symbol,
    uint8 _decimals,
    uint256 _totalSupply,
    uint8 _tokenPriceEther) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        totalSupply = _totalSupply;
        balanceOf[msg.sender] = _totalSupply;
        tokenPriceEther = _tokenPriceEther;

        riskKnowledgeCount = 0;
    }

    function buyToken() payable {
        uint numberOfTokens = msg.value / tokenPriceEther;
        balanceOf[msg.sender] += numberOfTokens;
        balanceOf[owner] -= numberOfTokens;
    }

    function getBalance(address member) constant returns(uint256 balance) {
        return balanceOf[member];
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
//
//        riskKnowledgeRatings[riskKnowledgeCount].initialized = 1;
//        riskKnowledgeRatings[riskKnowledgeCount].totalRating = 0;
//        riskKnowledgeRatings[riskKnowledgeCount].number == 0;

        riskKnowledgeCount++;

        return true;
    }

    function getRiskKnowledgeTitle(uint ind) constant returns(string title) {
        return riskKnowledgeTitles[ind];
    }

    function getRiskKnowledgeCount() constant returns(uint c) {
        return riskKnowledgeCount;
    }

    function requestRiskKnowledge(uint ind)
    returns(string) {
        require(ind < riskKnowledgeCount);

        return strConcat(riskKnowledgeTitles[ind],
            strConcatWithBytes("|",
                strConcatWithBytes(riskKnowledgeDescriptions[ind],
                    strConcatToBytes("|", riskKnowledgeLinks[ind])
                )
            )
        );
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
}
