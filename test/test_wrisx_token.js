var WrisxToken = artifacts.require("WrisxToken");

contract('WrisxToken', function(accounts) {
    it("should set owner as " + accounts[0], function() {
        return WrisxToken.deployed().then(function(instance) {
            return instance.getOwner.call();
        }).then(function(res) {
            assert.equal(res, accounts[0], "Owner should be " + accounts[0]);
        });
    });
})
