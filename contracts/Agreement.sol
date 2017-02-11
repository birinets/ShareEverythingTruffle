pragma solidity ^0.4.8;

/**
* Agreement between renter and owner.
* starts of as a request from the renter to the owner.
* then the owner can agree and the deal is settled.
*/
contract Agreement {
    enum State{
        REQUEST,
        AGREED,
        CANCELLED,
        DENIED,
        FINISHED
    }

    State _state;

    uint _assetId;

    address public _owner;
    address public _renter;

    uint public _startTime;
    uint public _endTime;

    /**
    *duration is in seconds.
    */
    function Agreement(uint id, address owner, address renter, uint duration) payable{
        _assetId = id;
        _owner = owner;
        _renter = renter;
        _startTime = now;
        _endTime = _startTime + duration;        
    }

    function changeState(State to){
        // all allowed state changes.
        // REQUEST -> AGREED
        // REQUEST -> DENIED
        // REQUEST -> CANCELLED
        // AGREED -> FINISHED
        if( (_state == State.REQUEST &&
            to == State.AGREED) ||
            (_state == State.REQUEST &&
            to == State.DENIED) ||
            (_state == State.REQUEST &&
            to == State.CANCELLED) ||
            (_state == State.AGREED &&
            to == State.FINISHED)) {
                _state = to;
            }else{
                throw;
            }
    }

    /**
    * allow for the owner to accept or denie the agreement.
    * return funds on denial.
    */
    function accept() {
        if(msg.sender != _owner) {throw;}
        changeState(State.AGREED);
    }

    /**
    * allow for the owner to deny the agreement.
    * return funds on denial.
    */
    function deny() {
        changeState(State.DENIED);
            //reset state(throw) if payout failed.
        if(!_renter.send(this.balance)){throw;}
    }

    /**
    * allow for the renter to cancel the contract.
    */
    function cancel(){
        if(msg.sender != _renter){throw;}
        changeState(State.CANCELLED);
            //reset state(throw) if payout failed.
        if(!_renter.send(this.balance)){throw;}
    }

    /**
    * allow for anyone to payout the money.
    */
    //TODO: make it possible for the owner(or anyone really) to payout money for the time that have passed. When the contract has not ended.
    // This should be calculated based on a percentage of time that has already passed (- what has been payed out before).
    function claim(){
        if(now > _endTime){
            changeState(State.FINISHED);
            //reset state(throw) if payout failed.
            if(!_owner.send(this.balance)){throw;}
        }
    }

    /**
    * fallback function to allow for money to be place on the contract.
    */
    function() payable{}

}