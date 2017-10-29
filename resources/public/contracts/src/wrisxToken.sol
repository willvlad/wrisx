pragma solidity ^0.4.17;

import "./mortal.sol";

contract WrisxToken is Mortal {
    event onRiskExpertRegistered(address indexed addr, string name);
    event onClientRegistered(address indexed addr, string name);
    event onFacilitatorRegistered(address indexed addr, string name);
    event onTokensBought(address indexed member, uint tokens);
    event onRiskKnowledgeDeposited(address indexed expert, string indexed uuid);
    event onRiskKnowledgeWithdrawn(address indexed expert, string indexed uuid);
    event onRiskKnowledgePaid(address indexed client, string indexed uuid);
    event onEnquiryPlaced(address indexed client, uint indexed enquiryId);
    event onBidPlaced(uint indexed enquiryId, uint indexed bidId, address indexed expert, uint price);
    event onBidExecuted(uint indexed bidId, string indexed riskKnowledgeUuid);
    event onRiskKnowledgeSent(address indexed client, string indexed uuid);
    event onRiskKnowledgeRatedByClient(address indexed client, string indexed uuid, uint rate);
    event onRiskKnowledgeRatedByFacilitator(address indexed client, string indexed uuid, uint rate);

    address public owner = msg.sender;

    uint MIN_RATING = 1;
    uint MAX_RATING = 10;

    struct RiskKnowledge {
    address expertAddress;
    uint256 price;
    string password;
    string zipFileChecksumMD5;
    RatingData ratingData;
    uint deposited;
    uint withdrawn;
    uint numberOfPurchases;
    }

    struct UserData {
    string name;
    uint256 balance;
    uint initialized;
    }

    struct ClientData {
    mapping (string => bool) purchases;
    mapping (string => Rating) ratings;
    mapping (uint => EnquiryData) enquiries;
    uint initialized;
    }

    struct RiskExpert {
    mapping (string => RiskKnowledge) riskKnowledgeItems;
    uint totalRating;
    uint number;
    uint initialized;
    }

    struct Facilitator {
    mapping (string => Rating) ratings;
    uint initialized;
    }

    struct RatingData {
    uint totalRatingByClient;
    uint numberOfClients;
    uint totalRatingByFacilitator;
    uint numberOfFacilitators;
    mapping (address => Rating) clientRatings;
    mapping (address => Rating) facilitatorRatings;
    }

    struct Rating {
    uint rating;
    string comment;
    uint done;
    }

    struct RiskKnowledgePurchase {
    uint totalRating;
    uint number;
    }

    struct EnquiryData {
    string keywords;
    uint initialized;
    mapping (uint => BidData) bids;
    }

    struct BidData {
    address expert;
    uint256 price;
    uint initialized;
    uint executed;
    uint timedout;
    string riskKnowledgeUuid;
    }

    mapping (address => UserData) public users;
    mapping (address => ClientData) public clients;
    mapping (address => RiskExpert) public riskExperts;
    mapping (address => Facilitator) public facilitators;
    mapping (string => RiskKnowledge) riskKnowledgeItems;

    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;
    uint256 public escrowBalance;
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
        users[msg.sender].balance = _totalSupply;
        tokenPriceEther = _tokenPriceEther;

        riskKnowledgeCount = 0;
        escrowBalance = 0;
    }

    function () public payable {

    }

    function buyTokens() public payable {
        uint numberOfTokens = msg.value / tokenPriceEther;

        require (users[owner].balance >= numberOfTokens);

        users[msg.sender].balance += numberOfTokens;
        users[owner].balance -= numberOfTokens;

        onTokensBought(msg.sender, numberOfTokens);
    }

    function getTokenPrice() public constant returns (uint8) {
        return tokenPriceEther;
    }

    function getBalance() public constant returns(uint256 balance) {
        return getMemberBalance(msg.sender);
    }

    function getMemberBalance(address member) public constant returns(uint256 balance) {
        return users[member].balance;
    }

    function registerRiskExpert(string _name) public returns (bool success) {
        require (riskExperts[msg.sender].initialized == 0);

        riskExperts[msg.sender].initialized = 1;
        registerUser(msg.sender, _name);

        onRiskExpertRegistered(msg.sender, _name);

        return true;
    }

    function registerClient(string _name) public returns (bool success) {
        require (clients[msg.sender].initialized == 0);

        clients[msg.sender].initialized = 1;
        registerUser(msg.sender, _name);

        onClientRegistered(msg.sender, _name);

        return true;
    }

    function registerFacilitator(string _name) public returns (bool success) {
        require (facilitators[msg.sender].initialized == 0);

        facilitators[msg.sender].initialized = 1;
        registerUser(msg.sender, _name);

        onFacilitatorRegistered(msg.sender, _name);

        return true;
    }

    function getExpertInitialized(address addr) public constant returns(uint init) {
        return riskExperts[addr].initialized;
    }

    function getClientInitialized(address addr) public constant returns(uint init) {
        return clients[addr].initialized;
    }

    function getFacilitatorInitialized(address addr) public constant returns(uint init) {
        return facilitators[addr].initialized;
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
    string _zipFileChecksumMD5,

    address _clientAddress,
    uint _enquiryId,
    uint _bidId) public
    returns (string) {
        require(riskKnowledgeItems[_uuid].deposited == 0);
        require(riskExperts[msg.sender].initialized == 1);

        riskKnowledgeItems[_uuid].expertAddress = msg.sender;
        riskKnowledgeItems[_uuid].price = _price;
        riskKnowledgeItems[_uuid].password = _password;
        riskKnowledgeItems[_uuid].zipFileChecksumMD5 = _zipFileChecksumMD5;
        riskKnowledgeItems[_uuid].deposited = 1;
        riskKnowledgeItems[_uuid].withdrawn = 0;

        riskKnowledgeItems[_uuid].ratingData.totalRatingByClient = 0;
        riskKnowledgeItems[_uuid].ratingData.numberOfClients = 0;
        riskKnowledgeItems[_uuid].ratingData.totalRatingByFacilitator = 0;
        riskKnowledgeItems[_uuid].ratingData.numberOfFacilitators = 0;

        riskExperts[msg.sender].riskKnowledgeItems[_uuid] = riskKnowledgeItems[_uuid];

        if (_bidId > 0) {
            require(users[_clientAddress].initialized == 1);
            require(clients[_clientAddress].initialized == 1);
            require(clients[_clientAddress].enquiries[_enquiryId].initialized == 1);
            require(clients[_clientAddress].enquiries[_enquiryId].bids[_bidId].initialized == 1);
            require(clients[_clientAddress].enquiries[_enquiryId].bids[_bidId].executed == 0);
            require(clients[_clientAddress].enquiries[_enquiryId].bids[_bidId].timedout == 0);

            clients[_clientAddress].enquiries[_enquiryId].bids[_bidId].riskKnowledgeUuid = _uuid;
            clients[_clientAddress].enquiries[_enquiryId].bids[_bidId].executed = 1;

            users[msg.sender].balance += clients[_clientAddress].enquiries[_enquiryId].bids[_bidId].price;
            escrowBalance -= clients[_clientAddress].enquiries[_enquiryId].bids[_bidId].price;
        }

        onRiskKnowledgeDeposited(msg.sender, _uuid);

        return _uuid;
    }

    function withdrawRiskKnowledge(string uuid) public
    returns (bool) {
        require(riskKnowledgeItems[uuid].expertAddress == msg.sender);
        require(riskExperts[msg.sender].initialized == 1);

        // TODO

        onRiskKnowledgeWithdrawn(msg.sender, uuid);
    }

    function requestRiskKnowledge(string uuid) public
    returns(string) {
        require(riskKnowledgeItems[uuid].deposited == 1);

        return riskKnowledgeItems[uuid].zipFileChecksumMD5;
    }

    function getRiskKnowledgePrice(string uuid) public constant
    returns(uint256) {
        require(riskKnowledgeItems[uuid].deposited == 1);

        return riskKnowledgeItems[uuid].price;
    }

    function getRiskKnowledgeExpert(string uuid) public
    returns(string) {
        require(riskKnowledgeItems[uuid].deposited == 1);

        address expertAddress = riskKnowledgeItems[uuid].expertAddress;

        return strConcat(addressToString(expertAddress),
            strConcatToBytes("|", users[expertAddress].name)
        );
    }

    function placeEnquiry(
    uint _enquiryId,
    string _keywords,
    uint _bidId0,
    address _expert0,
    uint256 _price0,
    uint _bidId1,
    address _expert1,
    uint256 _price1,
    uint _bidId2,
    address _expert2,
    uint256 _price2) public
    returns (bool) {
        require(clients[msg.sender].initialized == 1);
        require(clients[msg.sender].enquiries[_enquiryId].initialized == 0);

        clients[msg.sender].enquiries[_enquiryId].keywords = _keywords;
        clients[msg.sender].enquiries[_enquiryId].initialized = 1;
        addBid(msg.sender, _enquiryId, _bidId0, _expert0, _price0);
        addBid(msg.sender, _enquiryId, _bidId1, _expert1, _price1);
        addBid(msg.sender, _enquiryId, _bidId2, _expert2, _price2);

        onEnquiryPlaced(msg.sender, _enquiryId);

        return true;
    }

    function payForRiskKnowledge(string _uuid) public {
        require(users[msg.sender].balance >= riskKnowledgeItems[_uuid].price);

        users[riskKnowledgeItems[_uuid].expertAddress].balance += riskKnowledgeItems[_uuid].price;
        users[msg.sender].balance -= riskKnowledgeItems[_uuid].price;
        clients[msg.sender].purchases[_uuid] = true;

        onRiskKnowledgePaid(msg.sender, _uuid);
    }

    function getRiskKnowledge(string _uuid) public
    returns(string) {
        require(users[msg.sender].balance >= riskKnowledgeItems[_uuid].price);
        require(clients[msg.sender].purchases[_uuid] == true);

        onRiskKnowledgeSent(msg.sender, _uuid);

        return riskKnowledgeItems[_uuid].password;
    }

    function rateRiskKnowledgeByClient(string _uuid, uint _rate) public
    returns(bool) {
        require(clients[msg.sender].initialized == 1);
        require(riskKnowledgeItems[_uuid].deposited == 1);
        require(_rate <= MAX_RATING);
        require(_rate >= MIN_RATING);

        riskKnowledgeItems[_uuid].ratingData.totalRatingByClient += _rate;
        riskKnowledgeItems[_uuid].ratingData.numberOfClients++;
        riskExperts[riskKnowledgeItems[_uuid].expertAddress].totalRating + _rate;
        riskExperts[riskKnowledgeItems[_uuid].expertAddress].number++;

        onRiskKnowledgeRatedByClient(msg.sender, _uuid, _rate);

        return true;
    }

    function rateRiskKnowledgeByFacilitator(string _uuid, uint _rate) public
    returns(bool) {
        require(facilitators[msg.sender].initialized == 1);
        require(riskKnowledgeItems[_uuid].deposited == 1);
        require(_rate <= MAX_RATING);
        require(_rate >= MIN_RATING);

        riskKnowledgeItems[_uuid].ratingData.totalRatingByFacilitator += _rate;
        riskKnowledgeItems[_uuid].ratingData.numberOfFacilitators++;
        riskExperts[riskKnowledgeItems[_uuid].expertAddress].totalRating + _rate;
        riskExperts[riskKnowledgeItems[_uuid].expertAddress].number++;

        onRiskKnowledgeRatedByFacilitator(msg.sender, _uuid, _rate);

        return true;
    }

    function getRiskKnowledgeRatingByClient(string _uuid) public constant
    returns(uint256) {
        require(riskKnowledgeItems[_uuid].deposited == 1);

        if (riskKnowledgeItems[_uuid].ratingData.numberOfClients == 0) {
            return 0;
        }

        return riskKnowledgeItems[_uuid].ratingData.totalRatingByClient /
        riskKnowledgeItems[_uuid].ratingData.numberOfClients;
    }

    function getRiskKnowledgeRatingByFacilitator(string _uuid) public constant
    returns(uint256) {
        require(riskKnowledgeItems[_uuid].deposited == 1);

        if (riskKnowledgeItems[_uuid].ratingData.numberOfFacilitators == 0) {
            return 0;
        }

        return riskKnowledgeItems[_uuid].ratingData.totalRatingByFacilitator /
        riskKnowledgeItems[_uuid].ratingData.numberOfFacilitators;
    }

    function registerUser(address _addr, string _name) internal {
        if (users[_addr].initialized == 0) {
            users[_addr].name = _name;
        }
        users[_addr].initialized = 1;
    }

    function addBid(address _addr, uint _enquiryId, uint _bidId, address _expert, uint256 _price) internal {
        if (_bidId > 0) {
            require (users[_addr].balance >= _price);
            require (clients[_addr].enquiries[_enquiryId].bids[_bidId].initialized == 0);

            clients[_addr].enquiries[_enquiryId].bids[_bidId].expert = _expert;
            clients[_addr].enquiries[_enquiryId].bids[_bidId].price = _price;
            clients[_addr].enquiries[_enquiryId].bids[_bidId].executed = 0;
            clients[_addr].enquiries[_enquiryId].bids[_bidId].initialized = 1;
            clients[_addr].enquiries[_enquiryId].bids[_bidId].timedout = 0;
            escrowBalance += _price;
            users[_addr].balance -= _price;

            onBidPlaced(_enquiryId, _bidId, _expert, _price);
        }
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

    function stringToUint(string s) constant returns (uint result) {
        bytes memory b = bytes(s);
        uint i;
        result = 0;
        for (i = 0; i < b.length; i++) {
            uint c = uint(b[i]);
            if (c >= 48 && c <= 57) {
                result = result * 10 + (c - 48);
            }
        }
    }
}
