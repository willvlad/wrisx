pragma solidity ^0.4.17;

contract Owned {
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
}
