pragma solidity ^0.4.11;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/WrisxToken.sol";

contract TestWrisxToken {
    WrisxToken wrisxToken = WrisxToken(DeployedAddresses.WrisxToken());

    function testGetTokenPrice() public {
        uint returned = wrisxToken.getTokenPrice();

        uint expected = 1;

        Assert.equal(returned, expected, "Token price should be 1");
    }

    function testTotalSupply() public {
        uint returned = wrisxToken.totalSupply();

        uint expected = 10000;

        Assert.equal(returned, expected, "Total supply should be 10000");
    }
}
