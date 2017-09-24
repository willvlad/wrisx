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

    struct Rating {
    uint totalRating;
    uint number;
    uint initialized;
    }

    mapping (address => Rating) public riskExpertRatings;
    mapping (address => uint256) public balanceOf;

    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;

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
    }

    function getBalance(address member) constant returns(uint256 balance) {
        return this.balanceOf(member);
    }

    function getExpertInitialized(address expert) constant returns(uint init) {
        return riskExpertRatings[expert].initialized;
    }

    function getExpertTotalRating(address expert) constant returns(uint totalRating) {
        return riskExpertRatings[expert].totalRating;
    }

    function registerRiskExpert() returns (bool success) {
        require (riskExpertRatings[msg.sender].initialized == 0);

        riskExpertRatings[msg.sender].initialized = 1;

        return true;
    }
}
