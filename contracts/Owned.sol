pragma solidity ^0.4.8;

contract Owned {
    address public _owner;

    function Owned() {
        _owner = msg.sender;
    }

    modifier onlyOwner {
        if (msg.sender != _owner) throw;
        _;
    }
}
