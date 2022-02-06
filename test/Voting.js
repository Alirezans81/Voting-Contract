const Voting = artifacts.require("Voting");
contract("Voting", (accounts) => {
    let [alice, bob, carol] = accounts;

    let contractInstance;
    beforeEach(async () => {
        contractInstance = await Voting.new();
    });

    it("should be able to add a election", async() => {
        const result = await contractInstance.addElection(3600, 7200, {from: alice});
        assert.equal(result.receipt.status, true);
        assert.equal(result.logs[0].args.registration_period, 3600);
        assert.equal(result.logs[0].args.voting_period, 7200);
    })

    it("should be able to sign up", async() => {
        await contractInstance.addElection(3600, 7200, {from: alice});
        const result = await contractInstance.signUp(0, {from: bob});
        assert.equal(result.logs[0].args.signed_up_elections[0], 0);
    })

    it("should be able to vote", async() => {
        
    })
})