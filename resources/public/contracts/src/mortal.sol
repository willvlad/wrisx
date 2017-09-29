pragma solidity ^0.4.10;

import "owned.sol";

contract Mortal is Owned {
    function kill() {
        if (msg.sender == owner)
            selfdestruct(owner);
    }
}
