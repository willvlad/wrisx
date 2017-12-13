var WrisxToken = artifacts.require("WrisxToken");
const total_supply_param = 10000;
const token_price_param = 1;
var owner_account;
var expert_account;
var client_account;
var meta;


contract('WrisxToken', function(accounts) {
    it("should set owner as " + accounts[0], function() {
        return WrisxToken.deployed().then(function(instance) {
            meta = instance;
            owner_account = accounts[0];
            expert_account = accounts[1];
            client_account = accounts[2];
            return instance.getOwner.call();
        }).then(function(res) {
            assert.equal(res, owner_account, "Owner should be " + accounts[0]);
        });
    });

    it("should set token price as " + token_price_param, function() {
        return WrisxToken.deployed().then(function(instance) {
            return instance.getTokenPrice.call();
        }).then(function(res) {
            assert.equal(res, token_price_param,
                "Token price should be " + token_price_param);
        });
    });

    it("should send total supply to owner's account", function() {
        var meta;

        return WrisxToken.deployed().then(function(instance) {
            meta = instance;
            return meta.totalSupply();
        }).then(function(tot) {
            assert.equal(tot.toNumber(), total_supply_param,
                "Total supply should be " + total_supply_param);
            return meta.balanceOf.call(owner_account);
        }).then(function(res) {
            assert.equal(res.toNumber(), total_supply_param,
                "Owner's balance should be " + total_supply_param + " but was " + res);
        });
    });

    it("should register expert", function() {
        var meta;

        return WrisxToken.deployed().then(function(instance) {
            meta = instance;
            return meta.getExpertInitialized.call(expert_account);
        }).then(function(res) {
            assert.equal(res, 0, "Expert should not be registered " + expert_account);
            return meta.registerExpert("John", {from: expert_account});
        }).then(function() {
            return meta.getExpertInitialized.call(expert_account);
        }).then(function(res) {
            assert.equal(res, 1, "Expert should be registered " + expert_account);
        });
    });

    it("should register client", function() {
        var meta;

        return WrisxToken.deployed().then(function(instance) {
            meta = instance;
            return meta.getClientInitialized.call(client_account);
        }).then(function(res) {
            assert.equal(res, 0, "Client should not be registered " + client_account);
            return meta.registerClient("Matt", {from: client_account});
        }).then(function() {
            return meta.getClientInitialized.call(client_account);
        }).then(function(res) {
            assert.equal(res, 1, "Client should be registered " + client_account);
        });
    });
})
