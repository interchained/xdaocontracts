// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

contract ServiceDao {
    uint256 public constant maxTeammates = 1000;

    address[] public teammates;

    address public immutable goldenShare;

    uint256 public constant votingDuration = 72 hours;

    struct Voting {
        address contractAddress;
        bytes data;
        uint256 value;
        string comment;
        uint256 index;
        uint256 timestamp;
        bool isActivated;
        address[] signers;
    }

    Voting[] public votings;

    event VotingCreated(
        address contractAddress,
        bytes data,
        uint256 value,
        string comment,
        uint256 indexed index,
        uint256 timestamp
    );

    event VotingSigned(uint256 indexed index, address indexed signer, uint256 timestamp);

    event VotingActivated(uint256 indexed index, uint256 timestamp, bytes result);

    modifier teammatesOnly {
        bool isTeammate;

        for (uint256 i = 0; i < teammates.length; i++) {
            if (msg.sender == teammates[i]) {
                isTeammate = true;
                break;
            }
        }

        require(isTeammate);
        _;
    }

    modifier contractOnly {
        require(msg.sender == address(this));
        _;
    }

    constructor(address[] memory _teammates, address _goldenShare) {
        require(_teammates.length <= maxTeammates, "Too Many Teammates");

        teammates = _teammates;

        goldenShare = _goldenShare;
    }

    function createVoting(
        address _contractAddress,
        bytes calldata _data,
        uint256 _value,
        string memory _comment
    ) external teammatesOnly returns (bool success) {
        address[] memory _signers;

        votings.push(
            Voting({
                contractAddress: _contractAddress,
                data: _data,
                value: _value,
                comment: _comment,
                index: votings.length,
                timestamp: block.timestamp,
                isActivated: false,
                signers: _signers
            })
        );

        emit VotingCreated(_contractAddress, _data, _value, _comment, votings.length - 1, block.timestamp);

        return true;
    }

    function signVoting(uint256 _index) external teammatesOnly returns (bool success) {
        // Didn't vote yet
        for (uint256 i = 0; i < votings[_index].signers.length; i++) {
            require(msg.sender != votings[_index].signers[i]);
        }

        // Time is not over
        require(block.timestamp <= votings[_index].timestamp + votingDuration);

        votings[_index].signers.push(msg.sender);

        emit VotingSigned(_index, msg.sender, block.timestamp);

        return true;
    }

    function activateVoting(uint256 _index) external {
        require(votings[_index].signers.length > (teammates.length / 2));

        bool isGoldenShareVoted;

        for (uint256 i = 0; i < teammates.length; i++) {
            if (goldenShare == votings[_index].signers[i]) {
                isGoldenShareVoted = true;
                break;
            }
        }

        require(isGoldenShareVoted);

        require(!votings[_index].isActivated);

        address _contractToCall = votings[_index].contractAddress;

        bytes storage _data = votings[_index].data;

        uint256 _value = votings[_index].value;

        (bool b, bytes memory result) = _contractToCall.call{value: _value}(_data);

        require(b);

        votings[_index].isActivated = true;

        emit VotingActivated(_index, block.timestamp, result);
    }

    function addTeammate(address _newTeammate) public contractOnly returns (bool success) {
        for (uint256 i = 0; i < teammates.length; i++) {
            require(_newTeammate != teammates[i]);
        }

        teammates.push(_newTeammate);

        return true;
    }

    function removeTeammate(address _teammateToRemove) public contractOnly returns (bool success) {
        bool _found;
        uint256 _index;

        for (uint256 i = 0; i < teammates.length; i++) {
            if (_teammateToRemove == teammates[i]) {
                _found = true;
                _index = i;
                break;
            }
        }

        require(_found);

        teammates[_index] = teammates[teammates.length - 1];

        teammates.pop();

        return true;
    }

    function transferOfRights(address _oldTeammate, address _newTeammate) public contractOnly returns (bool success) {
        for (uint256 i = 0; i < teammates.length; i++) {
            require(_newTeammate != teammates[i]);
        }

        bool _found;
        uint256 _index;

        for (uint256 i = 0; i < teammates.length; i++) {
            if (_oldTeammate == teammates[i]) {
                _found = true;
                _index = i;
                break;
            }
        }

        require(_found);

        teammates[_index] = _newTeammate;

        return true;
    }

    function getAllTeammates() public view returns (address[] memory) {
        return teammates;
    }

    function getAllVotings() public view returns (Voting[] memory) {
        return votings;
    }
}
