pragma solidity >=0.7.0 <0.9.0;

contract Voting {

    uint addElectionFee = 0.0001 ether;

    struct Election {
        address creator;
        uint registration_period;
        uint voting_period;
        uint creating_time;
    }
    Election[] public elections;

    struct Condidate {
        address payable condidate_address;
        uint[] signed_up_elections;
        uint[] votes_per_election;
    }
    Condidate[] public condidates;
    mapping(address => Condidate) condidateDetails;
    
    mapping (address => uint[]) public Voter;

    function addElection(uint _registration_period, uint _voting_period) payable public {
        require(msg.value >= addElectionFee);
        elections.push(Election(msg.sender, _registration_period, _voting_period, block.timestamp));
    }

    function signUp(uint _election_index) public  {
        uint end_time = elections[_election_index].creating_time + elections[_election_index].registration_period;
        require(block.timestamp < end_time);
    
        bool signedUpBefore = false;
        for (uint i = 0; i < condidates.length; i++) {
            if (condidates[i].condidate_address == msg.sender) {
                bool alreadySigned = false;
                for (uint j = 0; j < condidates[i].signed_up_elections.length; j++) {
                    if (condidates[i].signed_up_elections[j] == _election_index) {
                        alreadySigned = true;
                    }
                }

                if (alreadySigned == false) {
                    condidates[i].signed_up_elections.push(_election_index);
                    condidates[i].votes_per_election.push(0);
                }

                signedUpBefore = true;
            }
        }

        require(signedUpBefore == false);
        
        uint[] memory _signed_up_elections;
        _signed_up_elections[_signed_up_elections.length] = _election_index;

        uint[] memory _votes_per_election;
        _votes_per_election[_votes_per_election.length] = 0;

        condidates.push(Condidate(payable(msg.sender) , _signed_up_elections, _votes_per_election));

        condidateDetails[msg.sender] = Condidate(payable(msg.sender) , _signed_up_elections, _votes_per_election);
        
    }

    function vote(uint _election_index, address _condidate_address) payable public {
        uint least = elections[_election_index].creating_time + elections[_election_index].registration_period;
        uint most = elections[_election_index].creating_time + elections[_election_index].registration_period + elections[_election_index].voting_period;
        if (block.timestamp < least || block.timestamp > most) {
            payable(msg.sender).transfer(msg.value);
        }
        require(block.timestamp >= least && block.timestamp < most);

        bool condidateExist = false;
        for(uint i = 0; i < condidates.length; i++) {
            if (condidates[i].condidate_address == _condidate_address) {
                bool isSignedUp = false;
                uint _index; 
                for (uint j = 0; j < condidates[i].signed_up_elections.length; j++) {
                    if (condidates[i].signed_up_elections[j] == _election_index) {
                        _index = j;

                        isSignedUp = true;
                    }
                }

                require(isSignedUp == true);

                condidates[i].votes_per_election[_index] += msg.value;
                
                condidateExist = true;
            }
        }

        require(condidateExist == true);

        uint[] memory theArray = Voter[msg.sender];
        theArray[_election_index] += msg.value;

        Voter[msg.sender] = theArray;
    }

    function endElection(uint _election_index) public view returns(address, uint) {
        uint shouldPass = elections[_election_index].creating_time + elections[_election_index].registration_period + elections[_election_index].voting_period;
        require(block.timestamp > shouldPass);

        address theWinner;
        uint mostVotes = 0;
        for (uint i = 0; i < condidates.length; i++) {
            for (uint j = 0; j < condidates[i].signed_up_elections.length; j++) {
                if (condidates[i].signed_up_elections[j] == _election_index) {
                    if (condidates[i].votes_per_election[j] > mostVotes) {
                        mostVotes = condidates[i].votes_per_election[j];
                        theWinner = condidates[i].condidate_address;
                    }
                }
            }
        }

        return (theWinner, mostVotes);
    }
}