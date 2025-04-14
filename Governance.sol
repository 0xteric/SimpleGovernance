// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Governance {
    struct Proposal {
        uint256 id;
        string description;
        uint256 yesVotes;
        uint256 noVotes;
        uint256 deadline;
        bool approved;
        address proposer;
    }

    uint public proposalCount;
    uint public VOTING_PERIOD = 3 days;
    address public admin;

    mapping(uint => Proposal) public proposals;
    mapping(address => uint) public votingPower;
    mapping(uint => mapping(address => bool)) public hasVoted;

    event ProposalCreated(uint id, string description, address proposer);
    event Voted(uint proposalId, address voter);

    constructor() {
        admin = msg.sender;
    }

    modifier onlyVoter() {
        require(votingPower[msg.sender] > 0, "User has 0 voting power.");
        _;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action.");
        _;
    }

    function updateVotingPower(address _voter, uint _power) external onlyAdmin {
        votingPower[_voter] = _power;
    }

    function vote(uint _id, bool _vote) external onlyVoter {
        Proposal storage proposal = proposals[_id];
        require(_id > 0 && _id <= proposalCount, "Invalid proposal ID.");
        require(block.timestamp < proposal.deadline, "Voting period ended.");
        require(!hasVoted[_id][msg.sender], "User already voted.");

        if (_vote) {
            proposal.yesVotes += votingPower[msg.sender];
        } else {
            proposal.noVotes += votingPower[msg.sender];
        }
        hasVoted[_id][msg.sender] = true;

        emit Voted(_id, msg.sender);
    }

    function createProposal(string memory _description) external {
        require(
            votingPower[msg.sender] > 1000,
            "At least 1000 voting power is need to create a proposal."
        );
        proposalCount++;
        proposals[proposalCount] = Proposal({
            id: proposalCount,
            description: _description,
            yesVotes: 0,
            noVotes: 0,
            deadline: block.timestamp + VOTING_PERIOD,
            approved: false,
            proposer: msg.sender
        });
        emit ProposalCreated(proposalCount, _description, msg.sender);
    }

    function executeProposal(uint _id) external {
        Proposal storage proposal = proposals[_id];
        require(
            block.timestamp > proposal.deadline,
            "Voting period still ongoing."
        );
        require(!proposal.approved, "Proposal already executed.");
        proposal.approved = proposal.yesVotes > proposal.noVotes;
    }
}
