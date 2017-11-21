pragma solidity ^0.4.17;

contract WrisxToken {
    address public owner = msg.sender;

    modifier onlyOwner {
        if (msg.sender != owner) revert();
        _;
    }

    function changeOwner(address _newOwner) public
    onlyOwner
    {
        if(_newOwner == 0x0) revert();
        owner = _newOwner;
    }

    function kill() public {
        if (msg.sender == owner)
        selfdestruct(owner);
    }

    event onExpertRegistered(address indexed addr, string name);
    event onClientRegistered(address indexed addr, string name);
    event onFacilitatorRegistered(address indexed addr, string name);
    event onTokensBought(address indexed member, uint tokens);
    event onResearchDeposited(address indexed expert, string indexed uuid);
    event onResearchWithdrawn(address indexed expert, string indexed uuid);
    event onResearchPaid(address indexed client, string indexed uuid);
    event onEnquiryPlaced(address indexed client, uint indexed enquiryId);
    event onBidPlaced(uint indexed enquiryId, uint indexed bidId, address indexed expert, uint price);
    event onBidExecuted(uint indexed bidId, string indexed researchUuid);
    event onResearchSent(address indexed client, string indexed uuid);
    event onResearchRatedByClient(address indexed client, string indexed uuid, uint rate);
    event onResearchRatedByFacilitator(address indexed client, string indexed uuid, uint rate);

    uint MIN_RATING = 1;
    uint MAX_RATING = 10;

    struct Research {
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

    struct Expert {
    mapping (string => Research) researchItems;
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
    uint rate;
    string comment;
    uint done;
    }

    struct ResearchPurchase {
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
    string researchUuid;
    }

    mapping (address => UserData) public users;
    mapping (address => ClientData) public clients;
    mapping (address => Expert) public experts;
    mapping (address => Facilitator) public facilitators;
    mapping (string => Research) researchItems;

    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;
    uint256 public escrowBalance;
    uint8 public tokenPriceEther;

    uint public researchCount;

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

        researchCount = 0;
        escrowBalance = 0;
    }

    function () public payable {

    }

    function buyTokens() public payable {
        require(users[msg.sender].initialized == 1);
        require(clients[msg.sender].initialized == 1);

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

    function registerExpert(string _name) public returns (bool success) {
        require(experts[msg.sender].initialized == 0);

        experts[msg.sender].initialized = 1;
        registerUser(msg.sender, _name);

        onExpertRegistered(msg.sender, _name);

        return true;
    }

    function registerClient(string _name) public returns (bool success) {
        require(clients[msg.sender].initialized == 0);

        clients[msg.sender].initialized = 1;
        registerUser(msg.sender, _name);

        onClientRegistered(msg.sender, _name);

        return true;
    }

    function registerFacilitator(string _name) public returns (bool success) {
        require(facilitators[msg.sender].initialized == 0);

        facilitators[msg.sender].initialized = 1;
        registerUser(msg.sender, _name);

        onFacilitatorRegistered(msg.sender, _name);

        return true;
    }

    function getExpertInitialized(address addr) public constant returns(uint init) {
        return experts[addr].initialized;
    }

    function getClientInitialized(address addr) public constant returns(uint init) {
        return clients[addr].initialized;
    }

    function getFacilitatorInitialized(address addr) public constant returns(uint init) {
        return facilitators[addr].initialized;
    }

    function getExpertTotalRating(address expertAddress) public constant returns(uint totalRating) {
        require (experts[expertAddress].initialized == 1);

        return experts[expertAddress].totalRating;
    }

    function getExpertRating(address expertAddress) public constant
    returns(uint256) {
        require (experts[expertAddress].initialized == 1);

        return experts[expertAddress].totalRating / experts[expertAddress].number;
    }

    function depositResearch(
    uint256 _price,
    string _uuid,
    string _password,
    string _zipFileChecksumMD5,

    address _clientAddress,
    uint _enquiryId,
    uint _bidId) public
    returns (string) {
        require(researchItems[_uuid].deposited == 0);
        require(experts[msg.sender].initialized == 1);
        require(users[msg.sender].initialized == 1);

        researchItems[_uuid].expertAddress = msg.sender;
        researchItems[_uuid].price = _price;
        researchItems[_uuid].password = _password;
        researchItems[_uuid].zipFileChecksumMD5 = _zipFileChecksumMD5;
        researchItems[_uuid].deposited = 1;
        researchItems[_uuid].withdrawn = 0;

        researchItems[_uuid].ratingData.totalRatingByClient = 0;
        researchItems[_uuid].ratingData.numberOfClients = 0;
        researchItems[_uuid].ratingData.totalRatingByFacilitator = 0;
        researchItems[_uuid].ratingData.numberOfFacilitators = 0;

        experts[msg.sender].researchItems[_uuid] = researchItems[_uuid];

        if (_bidId > 0) {
            require(users[_clientAddress].initialized == 1);
            require(clients[_clientAddress].initialized == 1);
            require(clients[_clientAddress].enquiries[_enquiryId].initialized == 1);
            require(clients[_clientAddress].enquiries[_enquiryId].bids[_bidId].initialized == 1);
            require(clients[_clientAddress].enquiries[_enquiryId].bids[_bidId].executed == 0);
            require(clients[_clientAddress].enquiries[_enquiryId].bids[_bidId].timedout == 0);

            clients[_clientAddress].enquiries[_enquiryId].bids[_bidId].researchUuid = _uuid;
            clients[_clientAddress].enquiries[_enquiryId].bids[_bidId].executed = 1;

            users[msg.sender].balance += clients[_clientAddress].enquiries[_enquiryId].bids[_bidId].price;
            escrowBalance -= clients[_clientAddress].enquiries[_enquiryId].bids[_bidId].price;
            clients[_clientAddress].purchases[_uuid] = true;

            researchItems[_uuid].numberOfPurchases = 1;

            onBidExecuted(_bidId, _uuid);
        } else {
            researchItems[_uuid].numberOfPurchases = 0;
        }

        onResearchDeposited(msg.sender, _uuid);

        return _uuid;
    }

    function withdrawResearch(string uuid) public
    returns (bool) {
        require(researchItems[uuid].expertAddress == msg.sender);
        require(experts[msg.sender].initialized == 1);

        // TODO

        onResearchWithdrawn(msg.sender, uuid);
    }

    function requestResearch(string uuid) public
    returns(string) {
        require(researchItems[uuid].deposited == 1);

        return researchItems[uuid].zipFileChecksumMD5;
    }

    function getResearchPrice(string uuid) public constant
    returns(uint256) {
        require(researchItems[uuid].deposited == 1);

        return researchItems[uuid].price;
    }

    function getResearchExpert(string uuid) public
    returns(string) {
        require(researchItems[uuid].deposited == 1);

        address expertAddress = researchItems[uuid].expertAddress;

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

    function payForResearch(string _uuid) public {
        require(clients[msg.sender].initialized == 1);
        require(users[msg.sender].balance >= researchItems[_uuid].price);
        require(researchItems[_uuid].deposited == 1);

        users[researchItems[_uuid].expertAddress].balance += researchItems[_uuid].price;
        users[msg.sender].balance -= researchItems[_uuid].price;
        researchItems[_uuid].numberOfPurchases += 1;
        clients[msg.sender].purchases[_uuid] = true;

        onResearchPaid(msg.sender, _uuid);
    }

    function getResearch(string _uuid) public
    returns(string) {
        require(users[msg.sender].balance >= researchItems[_uuid].price);
        require(clients[msg.sender].purchases[_uuid] == true);

        onResearchSent(msg.sender, _uuid);

        return researchItems[_uuid].password;
    }

    function rateResearchByClient(string _uuid, uint _rate, string _comment) public
    returns(bool) {
        require(clients[msg.sender].initialized == 1);
        require(researchItems[_uuid].deposited == 1);
        require(researchItems[_uuid].ratingData.clientRatings[msg.sender].done == 0);
        require(_rate <= MAX_RATING);
        require(_rate >= MIN_RATING);

        researchItems[_uuid].ratingData.totalRatingByClient += _rate;
        researchItems[_uuid].ratingData.numberOfClients++;
        experts[researchItems[_uuid].expertAddress].totalRating + _rate;
        experts[researchItems[_uuid].expertAddress].number++;

        researchItems[_uuid].ratingData.clientRatings[msg.sender].done = 1;
        researchItems[_uuid].ratingData.clientRatings[msg.sender].rate = _rate;
        researchItems[_uuid].ratingData.clientRatings[msg.sender].comment = _comment;

        onResearchRatedByClient(msg.sender, _uuid, _rate);

        return true;
    }

    function rateResearchByFacilitator(string _uuid, uint _rate, string _comment) public
    returns(bool) {
        require(facilitators[msg.sender].initialized == 1);
        require(researchItems[_uuid].deposited == 1);
        require(researchItems[_uuid].ratingData.facilitatorRatings[msg.sender].done == 0);
        require(_rate <= MAX_RATING);
        require(_rate >= MIN_RATING);

        researchItems[_uuid].ratingData.totalRatingByFacilitator += _rate;
        researchItems[_uuid].ratingData.numberOfFacilitators++;
        experts[researchItems[_uuid].expertAddress].totalRating + _rate;
        experts[researchItems[_uuid].expertAddress].number++;

        researchItems[_uuid].ratingData.facilitatorRatings[msg.sender].done = 1;
        researchItems[_uuid].ratingData.facilitatorRatings[msg.sender].rate = _rate;
        researchItems[_uuid].ratingData.facilitatorRatings[msg.sender].comment = _comment;

        onResearchRatedByFacilitator(msg.sender, _uuid, _rate);

        return true;
    }

    function getResearchRatingByClient(string _uuid) public constant
    returns(uint256) {
        require(researchItems[_uuid].deposited == 1);

        if (researchItems[_uuid].ratingData.numberOfClients == 0) {
            return 0;
        }

        return researchItems[_uuid].ratingData.totalRatingByClient /
        researchItems[_uuid].ratingData.numberOfClients;
    }

    function getResearchRatingByFacilitator(string _uuid) public constant
    returns(uint256) {
        require(researchItems[_uuid].deposited == 1);

        if (researchItems[_uuid].ratingData.numberOfFacilitators == 0) {
            return 0;
        }

        return researchItems[_uuid].ratingData.totalRatingByFacilitator /
        researchItems[_uuid].ratingData.numberOfFacilitators;
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

    function strConcat(string _a, bytes _bb) internal constant
    returns (string) {
        bytes memory _ba = bytes(_a);
        string memory ab = new string(_ba.length + _bb.length);
        bytes memory bab = bytes(ab);
        uint k = 0;
        for (uint i = 0; i < _ba.length; i++) bab[k++] = _ba[i];
        for (i = 0; i < _bb.length; i++) bab[k++] = _bb[i];

        return string(bab);
    }

    function strConcatToBytes(string _a, string _b) internal constant
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

    function strConcatWithBytes(string _a, bytes _bb) internal constant
    returns (bytes) {
        bytes memory _ba = bytes(_a);
        string memory ab = new string(_ba.length + _bb.length);
        bytes memory bab = bytes(ab);
        uint k = 0;
        for (uint i = 0; i < _ba.length; i++) bab[k++] = _ba[i];
        for (i = 0; i < _bb.length; i++) bab[k++] = _bb[i];

        return bab;
    }

    function addressToString(address x) internal constant returns (string) {
        bytes memory b = new bytes(20);
        for (uint i = 0; i < 20; i++)
        b[i] = byte(uint8(uint(x) / (2**(8*(19 - i)))));
        return string(b);
    }

    function stringToUint(string s) internal constant returns (uint result) {
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
