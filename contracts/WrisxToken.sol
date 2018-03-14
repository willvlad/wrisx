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
        if (_newOwner == 0x0) revert();
        owner = _newOwner;
    }

    function kill() public {
        if (msg.sender == owner)
        selfdestruct(owner);
    }

    event RegisterExpert(address indexed addr);

    event RegisterClient(address indexed addr);

    event RegisterFacilitator(address indexed addr);

    event BuyTokens(address indexed user, uint tokens);

    event DepositResearch(address indexed expert, string indexed uuid);

    event WithdrawResearch(address indexed expert, string indexed uuid);

    event PayForResearch(address indexed client, string indexed uuid);

    event PlaceEnquiry(address indexed client, uint indexed enquiryId);

    event PlaceBid(uint indexed enquiryId, uint indexed bidId, address indexed expert, uint price);

    event ExecuteBid(uint indexed bidId, string indexed researchUuid);

    event SendResearch(address indexed client, string indexed uuid);

    event RateResearchByClient(address indexed client, string indexed uuid, uint rate);

    event RateResearchByFacilitator(address indexed client, string indexed uuid, uint rate);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);

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
    uint256 balance;
    uint initialized;
    string secret;
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

    function() public payable {
        revert();
    }

    function getOwner() public constant returns (address) {
        return owner;
    }

    function totalSupply() public constant returns (uint _totalSupply) {
        return totalSupply;
    }

    function buyTokens() public payable {
        require(users[msg.sender].initialized == 1);
        require(clients[msg.sender].initialized == 1);

        uint numberOfTokens = msg.value / tokenPriceEther;
        require(users[owner].balance >= numberOfTokens);

        users[msg.sender].balance += numberOfTokens;
        users[owner].balance -= numberOfTokens;

        BuyTokens(msg.sender, numberOfTokens);
    }

    function getTokenPrice() public constant returns (uint8) {
        return tokenPriceEther;
    }

    function getBalance() public constant returns (uint256 balance) {
        return balanceOf(msg.sender);
    }

    function balanceOf(address _owner) public constant returns (uint256 balance) {
        return users[_owner].balance;
    }

    function transfer(address _to, uint256 _amount) public returns (bool success) {
        if (users[msg.sender].balance >= _amount
        && _amount > 0
        && users[_to].balance + _amount > users[_to].balance) {
            users[msg.sender].balance -= _amount;
            users[_to].balance += _amount;
            Transfer(msg.sender, _to, _amount);
            return true;
        }
        else {
            return false;
        }
    }

    function registerExpert(string _secret) public returns (bool success) {
        require(experts[msg.sender].initialized == 0);

        experts[msg.sender].initialized = 1;
        registerUser(msg.sender, _secret);

        RegisterExpert(msg.sender);

        return true;
    }

    function registerClient(string _secret) public returns (bool success) {
        require(clients[msg.sender].initialized == 0);

        clients[msg.sender].initialized = 1;
        registerUser(msg.sender, _secret);

        RegisterClient(msg.sender);

        return true;
    }

    function registerFacilitator(string _secret) public returns (bool success) {
        require(facilitators[msg.sender].initialized == 0);

        facilitators[msg.sender].initialized = 1;
        registerUser(msg.sender, _secret);

        RegisterFacilitator(msg.sender);

        return true;
    }

    function getExpertInitialized(address addr) public constant returns (uint init) {
        return experts[addr].initialized;
    }

    function getClientInitialized(address addr) public constant returns (uint init) {
        return clients[addr].initialized;
    }

    function getFacilitatorInitialized(address addr) public constant returns (uint init) {
        return facilitators[addr].initialized;
    }

    function getExpertTotalRating(address expertAddress) public constant returns (uint totalRating) {
        require(experts[expertAddress].initialized == 1);

        return experts[expertAddress].totalRating;
    }

    function getExpertRating(address expertAddress) public constant
    returns (uint256) {
        require(experts[expertAddress].initialized == 1);

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

            ExecuteBid(_bidId, _uuid);
        }
        else {
            researchItems[_uuid].numberOfPurchases = 0;
        }

        DepositResearch(msg.sender, _uuid);

        return _uuid;
    }

    function withdrawResearch(string uuid) public
    returns (bool) {
        require(researchItems[uuid].expertAddress == msg.sender);
        require(experts[msg.sender].initialized == 1);

        // TODO

        WithdrawResearch(msg.sender, uuid);
    }

    function requestResearch(string uuid) public view
    returns (string) {
        require(researchItems[uuid].deposited == 1);

        return researchItems[uuid].zipFileChecksumMD5;
    }

    function getResearchPrice(string uuid) public constant
    returns (uint256) {
        require(researchItems[uuid].deposited == 1);

        return researchItems[uuid].price;
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

        PlaceEnquiry(msg.sender, _enquiryId);

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

        PayForResearch(msg.sender, _uuid);
    }

    function getResearch(string _uuid) public
    returns (string) {
        require(clients[msg.sender].purchases[_uuid] == true);

        SendResearch(msg.sender, _uuid);

        return researchItems[_uuid].password;
    }

    function rateResearchByClient(string _uuid, uint _rate, string _comment) public
    returns (bool) {
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

        RateResearchByClient(msg.sender, _uuid, _rate);

        return true;
    }

    function rateResearchByFacilitator(string _uuid, uint _rate, string _comment) public
    returns (bool) {
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

        RateResearchByFacilitator(msg.sender, _uuid, _rate);

        return true;
    }

    function getResearchRatingByClient(string _uuid) public constant
    returns (uint256) {
        require(researchItems[_uuid].deposited == 1);

        if (researchItems[_uuid].ratingData.numberOfClients == 0) {
            return 0;
        }

        return researchItems[_uuid].ratingData.totalRatingByClient /
        researchItems[_uuid].ratingData.numberOfClients;
    }

    function getResearchRatingByFacilitator(string _uuid) public constant
    returns (uint256) {
        require(researchItems[_uuid].deposited == 1);

        if (researchItems[_uuid].ratingData.numberOfFacilitators == 0) {
            return 0;
        }

        return researchItems[_uuid].ratingData.totalRatingByFacilitator /
        researchItems[_uuid].ratingData.numberOfFacilitators;
    }

    function registerUser(address _addr, string _secret) internal {
        if (users[_addr].initialized == 0) {
            users[_addr].initialized = 1;
            users[_addr].secret = _secret;
        }
    }

    function getSecret() public constant
    returns (string) {
        require(users[msg.sender].initialized == 1);
        return users[msg.sender].secret;
    }

    function addBid(address _addr, uint _enquiryId, uint _bidId, address _expert, uint256 _price) internal {
        if (_bidId > 0) {
            require(users[_addr].balance >= _price);
            require(clients[_addr].enquiries[_enquiryId].bids[_bidId].initialized == 0);

            clients[_addr].enquiries[_enquiryId].bids[_bidId].expert = _expert;
            clients[_addr].enquiries[_enquiryId].bids[_bidId].price = _price;
            clients[_addr].enquiries[_enquiryId].bids[_bidId].executed = 0;
            clients[_addr].enquiries[_enquiryId].bids[_bidId].initialized = 1;
            clients[_addr].enquiries[_enquiryId].bids[_bidId].timedout = 0;
            escrowBalance += _price;
            users[_addr].balance -= _price;

            PlaceBid(_enquiryId, _bidId, _expert, _price);
        }
    }
}
