pragma solidity ^0.4.17;

import "./owned.sol";

contract Mortal is Owned {
    function kill() public {
        if (msg.sender == owner)
            selfdestruct(owner);
    }
}
