// Specifically request an abstraction for MetaCoin.sol
var Owner = artifacts.require("./Owner.sol");

contract('Owner', function(accounts) {

    var ownerInstance;
    it("should add an item to an owner.", function() {
        return Owner.deployed().then(function(instance) {
            ownerInstance = instance;

            //console.log("owner instance: \n", ownerInstance);
            // add an asset, arguments: id, description, pricePerTimeUnit, TimeUnit(days in this case.), 
            return instance.addAsset(1,"awesome set of speakers.",50,2,{from:accounts[0]});
        }).then(function() {
            return ownerInstance._assets.call();
        }).then(function(assets){
            console.log("assets: \n", assets);
        });
    });
});