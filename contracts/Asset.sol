pragma solidity ^0.4.8;

import "./Owned.sol";
import "./Agreement.sol";

/**
* An asset is a blockchain representation of a physical item a person can let(rent out).
* This Asset will be created by an OwnerContract
* All prices are in WEI.
*/
contract Asset is Owned{

    /**
    * Available (time units) for which an asset can be rented.
    */
    enum TimeUnit {
        HOUR,
        DAY,
        WEEK
    }

    /**
    *  address of the latest renter.
    *    0x0 if it hasn't been rented. 
    */
    //TODO: it actually is current wannabee renter. As the agreement might not have been accepted.
    address public _currentAgreement;

    /**
    * Description of the item.
    */
    //TODO: Should we limit this to a certain amount of characters?, maybe a bytes object. (and certain kind of characters?)
    string public _description; 
    function setDescription(string description) onlyOwner{
        _description = description;
    }

    /**
    * ID to link a physical item to the blockchain.
    */
    //TODO: how large?
    uint public _id; 
    function setID(uint id) onlyOwner{
        _id = id;
    }

    /**
    * The price of the asset per time unit. E.g. 50 ether per day.
    */
    uint public _pricePerTimeUnit;
    function setPricePerTimeUnit(uint price) onlyOwner{
        _pricePerTimeUnit = price;
    }

    /**
    * time unit for which this asset can be rented.
    */
    TimeUnit public _timeUnit;
    function setTimeUnit(TimeUnit timeUnit) onlyOwner{
        _timeUnit = timeUnit;
    }

    /**
    * This constructor will create an asset.
    * it should be called by an OwnerContract to correctly work with the ShareEverything application.
    */
    //TODO: can we limit the constructor to be only called by a certain contract type?
    function Asset(uint id, string description, uint pricePerTimeUnit, TimeUnit timeUnit){ 
        _id = id;
        _description = description;
        _pricePerTimeUnit = pricePerTimeUnit;
        _timeUnit = timeUnit;
    }

    /**
    * remove the contract. Can only be executed by the owner.
    * this will set all values to 0 and make it impossible to interact with.
    * money will be send to the owner.
    * can only be called if the asset is notRented.
    */
    function remove() onlyOwner notRented {
        selfdestruct(_owner);
    }

    /**
    * Rent this asset for a specific amount of time.
    * unitsOfTime is the amount of time units the renter wants to rent the Asset.
    */
    function rent(uint unitsOfTime) payable notRented {

        //Check if the value to pay is exactly enough.
        //TODO: too much could be a tip?
        uint totalPrice = _pricePerTimeUnit * unitsOfTime;
        if(msg.value != totalPrice) {throw;}

        uint duration = calculateDuration(_timeUnit, unitsOfTime);

        //create new agreement, forward the money and mark as unavailable(setting a valid agreement).
        _currentAgreement = (new Agreement).value(msg.value)(_id, _owner, msg.sender, duration);
    }

    function calculateDuration(TimeUnit timeUnit, uint unitsOfTime) returns (uint){
        if(timeUnit == TimeUnit.HOUR){
            return (1 hours * unitsOfTime);
        }else if(timeUnit == TimeUnit.DAY){
            return (1 days * unitsOfTime);
        }else if(timeUnit == TimeUnit.WEEK){
            return (1 weeks * unitsOfTime);
        }
    }

    function collect() onlyOwner rented{
        Agreement agreement = Agreement(_currentAgreement);
        agreement.claim();
        _currentAgreement = 0x0;
    }

    modifier notRented {
        if (_currentAgreement != 0x0)
            throw;
        _;
    }

    modifier rented{
        if (_currentAgreement == 0x0)
            throw;
        _;
    }
}