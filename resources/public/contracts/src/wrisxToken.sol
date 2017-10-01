pragma solidity ^0.4.10;

import "mortal.sol";

contract WrisxToken is Mortal {

    struct RiskKnowledge {
    address expertAddress;
    uint256 price;
    string title;
    string keyWord;
    string description;
    string link;
    string hash;
    string password;
    RiskKnowledgeRating rating;
    bool withdrawn;
    }

    struct RiskExpertRating {
    string name;
    uint totalRating;
    uint number;
    uint initialized;
    }

    struct RiskKnowledgeRating {
    uint totalRating;
    uint number;
    }

    mapping (address => uint256) public balanceOf;
    mapping (address => RiskExpertRating) public riskExpertRatings;
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
    uint8 _tokenPriceEther) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        totalSupply = _totalSupply;
        balanceOf[msg.sender] = _totalSupply;
        tokenPriceEther = _tokenPriceEther;

        riskKnowledgeCount = 0;
    }

    function () payable {
        buyToken();
    }

    function buyToken() payable {
        uint numberOfTokens = msg.value / tokenPriceEther;

        require (balanceOf[owner] >= numberOfTokens);

        balanceOf[msg.sender] += numberOfTokens;
        balanceOf[owner] -= numberOfTokens;
    }

    function getBalance() constant returns(uint256 balance) {
        return getMemberBalance(msg.sender);
    }

    function getMemberBalance(address member) constant returns(uint256 balance) {
        return balanceOf[member];
    }

    function registerRiskExpert(string _name) returns (bool success) {
        require (riskExpertRatings[msg.sender].initialized == 0);

        riskExpertRatings[msg.sender].initialized = 1;
        riskExpertRatings[msg.sender].name = _name;

        return true;
    }

    function getExpertInitialized(address expertAddress) constant returns(uint init) {
        return riskExpertRatings[expertAddress].initialized;
    }

    function getExpertTotalRating(address expertAddress) constant returns(uint totalRating) {
        require (riskExpertRatings[expertAddress].initialized == 1);

        return riskExpertRatings[expertAddress].totalRating;
    }

    function getExpertRating(address expertAddress)
    returns(uint256) {
        require (riskExpertRatings[expertAddress].initialized == 1);

        return riskExpertRatings[expertAddress].totalRating / riskExpertRatings[expertAddress].number;
    }

    function depositRiskKnowledge(
    uint256 _price,
    string _title,
    string _keyWord,
    string _description,
    string _link,
    string _hash,
    string _password)
    returns (bool success) {
        require (riskExpertRatings[msg.sender].initialized == 1);

        riskKnowledgeArray[riskKnowledgeCount].expertAddress = msg.sender;
        riskKnowledgeArray[riskKnowledgeCount].price = _price;
        riskKnowledgeArray[riskKnowledgeCount].title = _title;
        riskKnowledgeArray[riskKnowledgeCount].keyWord = _keyWord;
        riskKnowledgeArray[riskKnowledgeCount].description = _description;
        riskKnowledgeArray[riskKnowledgeCount].link = _link;
        riskKnowledgeArray[riskKnowledgeCount].hash = _hash;
        riskKnowledgeArray[riskKnowledgeCount].password = _password;

        riskKnowledgeArray[riskKnowledgeCount].rating.totalRating = 0;
        riskKnowledgeArray[riskKnowledgeCount].rating.number = 0;

        riskKnowledgeCount++;

        return true;
    }

    function getRiskKnowledgeTitle(uint ind) constant returns(string title) {
        return riskKnowledgeArray[ind].title;
    }

    function getRiskKnowledgeCount() constant returns(uint c) {
        return riskKnowledgeCount;
    }

    function requestRiskKnowledge(uint ind)
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

    function getRiskKnowledgePrice(uint ind)
    returns(uint256) {
        require(ind < riskKnowledgeCount);

        return riskKnowledgeArray[ind].price;
    }

    function buyRiskKnowledge(uint ind)
    returns(string) {
        require(ind < riskKnowledgeCount);
        require(balanceOf[msg.sender] >= riskKnowledgeArray[ind].price);

        balanceOf[riskKnowledgeArray[ind].expertAddress] += riskKnowledgeArray[ind].price;
        balanceOf[msg.sender] -= riskKnowledgeArray[ind].price;

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

    function rateRiskKnowledge(uint ind, uint rate)
    returns(bool) {
        require(ind < riskKnowledgeCount);

        riskKnowledgeArray[ind].rating.totalRating += rate;
        riskKnowledgeArray[ind].rating.number++;

        return true;
    }

    function getRiskKnowledgeRating(uint ind)
    returns(uint256) {
        require(ind < riskKnowledgeCount);

        return riskKnowledgeArray[ind].rating.totalRating / riskKnowledgeArray[ind].rating.number;
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
