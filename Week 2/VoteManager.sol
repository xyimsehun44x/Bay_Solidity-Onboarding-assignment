// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract VoteManager {
    // --- Candidates ---
    string[] public candidates;
    mapping(uint => uint) public votes;

    // --- Voter tracking ---
    mapping(address => bool)    public hasVoted;
    mapping(address => uint)    public voteTimestamp;
    address[]                  public voterList;

    // --- Voting window ---
    uint public startTime;
    uint public endTime;

    // --- Events ---
    event Voted(
        address indexed voter,
        uint    indexed candidate,
        uint             timestamp
    );

    /// @notice Deploy and set your voting window here (absolute UNIX timestamps)
    constructor(uint _startTime, uint _endTime) {
        require(_startTime >= block.timestamp, "start>=now");
        require(_endTime > _startTime,    "end>start");

        startTime = _startTime;
        endTime   = _endTime;

        // --- hard‑coded 5 candidates ---
        candidates.push("Alice");
        candidates.push("Bob");
        candidates.push("Charlie");
        candidates.push("Dave");
        candidates.push("Eve");
    }

    // --- Modifiers ---
    modifier onlyDuringVoting() {
        require(block.timestamp >= startTime, "not started");
        require(block.timestamp <= endTime,   "already ended");
        _;
    }

    modifier notVoted() {
        require(!hasVoted[msg.sender], "already voted");
        _;
    }

    /// @notice Cast your vote by index [0‥4]
    function vote(uint _candidateIndex)
        external
        onlyDuringVoting
        notVoted
    {
        require(_candidateIndex < candidates.length, "invalid candidate");

        // record the vote
        votes[_candidateIndex] += 1;
        hasVoted[msg.sender]     = true;
        voteTimestamp[msg.sender] = block.timestamp;
        voterList.push(msg.sender);

        emit Voted(msg.sender, _candidateIndex, block.timestamp);
    }

    // --- Convenience getters ---

    /// @notice return all candidates
    function getCandidates() external view returns (string[] memory) {
        return candidates;
    }

    /// @notice how many unique voters have voted
    function getVoterCount() external view returns (uint) {
        return voterList.length;
    }

    /// @notice get the full list of who voted (and in what order)
    function getVoters() external view returns (address[] memory) {
        return voterList;
    }
}
