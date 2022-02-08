const Voting = artifacts.require("Voting");
const utils = require("./helpers/utils");
const time = require("./helpers/time");
contract("Voting", (accounts) => {
    let [alice, bob, carol] = accounts;

    let contractInstance;
    beforeEach(async () => {
        contractInstance = await Voting.new();
    });

    it("should be able to add an election", async() => {
        const result = await contractInstance.addElection(3600, 7200, {from: alice});
        assert.equal(result.receipt.status, true);
        assert.equal(result.logs[0].args.registration_period, 3600);
        assert.equal(result.logs[0].args.voting_period, 7200);
    })

    it("should be able to sign up", async() => {
        const election_result = await contractInstance.addElection(3600, 7200, {from: alice});
        const electionId = election_result.logs[0].args.electionId.toNumber();
        const result = await contractInstance.signUp(electionId, {from: bob});
        const condidateId = result.log[0].args.condidateId.toNumber();
        assert.equal(result.receipt.status, true);
        
        
        //assert.equal(result.logs[0].args.condidates[condidateId].votes_per_election[electionId], 0);
        //assert.equal(result.logs[0].args.condidates[condidateId].votes_per_election[electionId], 0);
    })

    it("should be able to vote", async() => {
        const election_result = await contractInstance.addElection(3600, 7200, {from: alice});
        const electionId = election_result.log[0].args.electionId.toNumber();
        await contractInstance.signUp(electionId, {from: bob});
        await time.increase(time.duration.hours(1));
        const result = await contractInstance.vote(electionId, bob, {from: carol});
        assert.equal(result.receipt.status, true);
        assert.equal(result.logs[0].args.condidates[condidateId].votes_per_election[electionId], 0);
        assert.equal(result.logs[0].args.condidates[condidateId].votes_per_election[electionId], 0);
    })
})
