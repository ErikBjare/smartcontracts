// Basic voting contract
// Based on the example here: https://github.com/ethereum/browser-solidity/blob/3a8f60d85a097a16a28a46ddd2aee3cdcdcad0c4/src/app/editor/example-contracts.js

pragma solidity ^0.4.0;

contract Ballot {

    struct Voter {
        uint votesAwarded;
        uint votesPlaced;
        string vote;
        address delegate;
    }

    struct Proposal {
        uint voteCount;
    }

    address chairperson;
    mapping(address => Voter) voters;
    mapping(string => Proposal) proposals;
    string leadingProposal;

    /// Create a new ballot with $(_numProposals) different proposals.
    function Ballot() {
        chairperson = msg.sender;
        voters[chairperson].votesAwarded = 1;
    }

    /// Give $(votes) number of votes to voter $(voter)
    /// May only be called by $(chairperson).
    function giveVotes(address voter, uint8 votes) {
        if (msg.sender != chairperson) return;
        if (voters[voter].votesPlaced >= voters[voter].votesAwarded) return;
        voters[voter].votesAwarded = 1;
    }

    /// Delegate your vote to the voter $(to).
    function delegate(address to, uint8 votes) {
        Voter storage sender = voters[msg.sender]; // assigns reference
        if (sender.votesPlaced >= sender.weight + votes) return;

        // Resolves an eventual delegation chain
        while (voters[to].delegate != address(0) && voters[to].delegate != msg.sender)
            to = voters[to].delegate;

        if (to == msg.sender) return;

        sender.votesPlaced += votes;
        sender.delegate = to;
        Voter storage delegateTo = voters[to];
        if (delegateTo.voted)
            proposals[delegateTo.vote].voteCount += sender.votesender.weight;
        else
            delegateTo.weight += sender.weight;
    }

    /// Place a vote
    function vote(string _proposalName) {
        Voter storage sender = voters[msg.sender];
        if (sender.voted) return;
        sender.voted = true;
        sender.vote = _proposalName;
        proposals[_proposalName].voteCount += sender.weight;
    }

    function winningProposal() constant returns (string _winningProposal) {
        return leadingProposal;
    }
}
