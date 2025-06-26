// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IStaking {
    function stakedBalance(address _user) external view returns (uint);
}

contract Governance {
    IStaking public staking;

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
    mapping(uint => mapping(address => bool)) public hasVoted;

    event ProposalCreated(uint id, string description, address proposer);
    event Voted(uint proposalId, address voter);

    constructor(address _stakingContract) {
        admin = msg.sender;
        staking = IStaking(_stakingContract);
    }

    modifier onlyVoter() {
        require(getVotingPower(msg.sender) > 0, "User has 0 voting power.");
        _;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action.");
        _;
    }

    /** Checks the voting power of stakers based on the staked balance
     * @param _voter address to check its voting power
     */
    function getVotingPower(address _voter) public view returns (uint) {
        return staking.stakedBalance(_voter);
    }

    /**
     * Votes TRUE or FALSE on a proposal, voting amount depends on user voting power.
     * @param _id Id of the proposal to vote
     * @param _vote Side of the vote (TRUE/FALSE)
     */
    function vote(uint _id, bool _vote) external onlyVoter {
        Proposal storage proposal = proposals[_id];
        require(_id > 0 && _id <= proposalCount, "Invalid proposal ID.");
        require(block.timestamp < proposal.deadline, "Voting period ended.");
        require(!hasVoted[_id][msg.sender], "User already voted.");

        if (_vote) {
            proposal.yesVotes += getVotingPower(msg.sender);
        } else {
            proposal.noVotes += getVotingPower(msg.sender);
        }
        hasVoted[_id][msg.sender] = true;

        emit Voted(_id, msg.sender);
    }

    /**
     * Users with at least 1000 staked tokens can make proposals
     * @param _description Description of the proposal
     */

    function createProposal(string memory _description) external {
        require(
            getVotingPower(msg.sender) > 1000,
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

    /**
     * Executes the voting result of a proposal if YES > NO then the proposal is accepted
     * @param _id Proposal id
     */

    function executeProposal(uint _id) external {
        Proposal storage proposal = proposals[_id];
        require(
            block.timestamp > proposal.deadline,
            "Voting period still ongoing."
        );
        require(!proposal.approved, "Proposal already executed.");
        proposal.approved = proposal.yesVotes > proposal.noVotes;
    }

    /**
     * Updates contract admin
     * @param _admin New admin address
     */
    function changeAdmin(address _admin) public onlyAdmin {
        admin = _admin;
    }
}
