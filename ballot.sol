// Basic voting contract
// Based on the example here: https://github.com/ethereum/browser-solidity/blob/3a8f60d85a097a16a28a46ddd2aee3cdcdcad0c4/src/app/editor/example-contracts.js

pragma solidity ^0.4.0;

contract Ballot {

    struct Voter {
        uint votesAwarded;
        uint votesDelegated;
        uint votesPlaced;
    }

    struct Proposal {
        uint voteCount;
        string name;
    }

    event VoteEvent(string _proposalName, uint _votes, address _voter);

    address chairperson;
    mapping(address => Voter) voters;

    Proposal[] proposals;
    //mapping(string => uint8) proposalsByName;

    /// Create a new ballot.
    function Ballot() {
        chairperson = msg.sender;
        voters[chairperson].votesAwarded = 1;
    }

    /// INTERNAL: Returns the remaining votes available for use by the calling Voter
    function remainingVotes() internal returns (uint _votes) {
        Voter storage voter = voters[msg.sender];
        return voter.votesAwarded
             - voter.votesDelegated
             - voter.votesPlaced;
    }

    /// Name a proposal, can only be done by the chairperson.
    function addProposal(string _name) {
        if (msg.sender != chairperson) return;

        // Prevent two proposals with identical names
        for (uint8 proposal = 0; proposal < proposals.length; proposal++) {
            if (sha3(proposals[proposal].name) == sha3(_name)) return;
        }

        // Create the proposal
        proposals.length += 1;
        proposals[proposals.length-1] = Proposal(0, _name);
    }

    /// Give voter $(voter) an additional $(votes) votes.
    /// May only be called by $(chairperson).
    function giveVotes(address voter, uint votes) {
        if (msg.sender != chairperson) return;
        voters[voter].votesAwarded += votes;
    }

    /// Delegate your vote to the voter $(to).
    function delegate(address _to, uint _votes) {
        Voter storage sender = voters[msg.sender]; // assigns reference
        if (remainingVotes() <= _votes) return;

        // Forbid sending votes to oneself, prevents int overflow exploit.
        // TODO: int overflow still possible by delegating to another account and then back.
        if (msg.sender == _to) return;

        sender.votesPlaced += _votes;
        Voter storage delegateTo = voters[_to];
        delegateTo.votesAwarded += _votes;
    }

    /// Place a vote
    function vote(uint8 _proposalId, uint _votes) {
        Voter storage _sender      = voters[msg.sender];
        Proposal storage _proposal = proposals[_proposalId];
        if (remainingVotes() < _votes) return;

        _sender.votesPlaced -= _votes;
        _proposal.voteCount += _votes;

        VoteEvent(_proposal.name, _votes, msg.sender);
    }

    function winningProposal() constant returns (uint8 _winningProposal) {
        uint256 winningVoteCount = 0;
        for (uint8 proposal = 0; proposal < proposals.length; proposal++) {
            if (proposals[proposal].voteCount > winningVoteCount) {
                winningVoteCount = proposals[proposal].voteCount;
                _winningProposal = proposal;
            }
        }
    }
}
