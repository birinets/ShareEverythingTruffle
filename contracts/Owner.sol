pragma solidity ^0.4.8;

import "./Asset.sol";
import "./Owned.sol";

/**
* Owner-contract is responsible for the links to the addressess of the assets in the chain.
*/
contract Owner is Owned{

    /**
    * assets belonging to the owner.
    */
    //TODO: perhaps implement a linked list if we want more then a certain amount of assets?
    //https://github.com/ethereum/dapp-bin/blob/master/library/linkedList.sol
    address[256] public _assets;
    uint8 _freeSlot;
    mapping(address => uint8) _addressToList;

    function Owner(){
        _owner = msg.sender;
    }   

    /**
    * Add an asset.
    */
    function addAsset(uint id, string description, uint pricePerTimeUnit, Asset.TimeUnit timeUnit) onlyOwner {
        address newAsset = new Asset(id, description, pricePerTimeUnit, timeUnit);
        var slot = _freeSlot;
        _assets[slot] = newAsset;
        _addressToList[newAsset] = slot;
        setFreeSlot(slot, 0);
    }

    /**
    * remove an asset from based on address.
    */
    // TODO: what if an address is given that is not in the list?
    // because the mapping will return 0 for an address that is not mapped.
    // and 0 is a valid list identifier.
    function removeAsset(address addr) onlyOwner{
        //'Delete' asset.
        Asset asset = Asset(addr);
        asset.remove();
        
        //Remove from list.
        uint8 slot = _addressToList[addr];
        _assets[slot] = 0x0;
        //Set _freeSlot to keep the list from fragmentation.
        _freeSlot = slot; 

    }

    /**
    * set the next free slot to use to store an Asset.
    * recursive function.
    */
    function setFreeSlot(uint8 current, uint iterations) private {
        uint8 next = current + 1;

        // loop back to start.
        //if(next >= 256){next = 0;}
        //TODO: Verify: Not needed to check if we loop around as uint8 can only contain 256 entries.

        if(_assets[next] == 0x0){
            _freeSlot = next;
        }else{
            if(iterations >=256) {throw;}
            setFreeSlot(next, (iterations + 1));
        }
    }

}