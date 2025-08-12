// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title FluxBridge On-Chain Registry
/// @notice Stores attestations and signal hashes produced by the FluxBridge engine.
/// @dev Authorised reporters publish scored signals that downstream contracts can consume.
contract FluxBridgeRegistry {
    address public owner;
    uint256 public signalCount;

    struct Signal {
        bytes32 hash;
        uint256 score; // scaled basis points, 0 - 10000
        uint256 timestamp;
        address reporter;
    }

    mapping(uint256 => Signal) public signals;
    mapping(address => bool) public authorized;

    event SignalPublished(uint256 indexed id, bytes32 hash, uint256 score);
    event AuthorizationChanged(address indexed account, bool status);

    modifier onlyOwner() {
        require(msg.sender == owner, "not owner");
        _;
    }

    modifier onlyAuthorized() {
        require(authorized[msg.sender], "not authorized");
        _;
    }

    constructor() {
        owner = msg.sender;
        authorized[msg.sender] = true;
    }

    function setAuthorization(address account, bool status) external onlyOwner {
        authorized[account] = status;
        emit AuthorizationChanged(account, status);
    }

    function publishSignal(bytes32 hash, uint256 score)
        external
        onlyAuthorized
        returns (uint256 id)
    {
        require(score <= 10000, "score out of range");
        id = ++signalCount;
        signals[id] = Signal({
            hash: hash,
            score: score,
            timestamp: block.timestamp,
            reporter: msg.sender
        });
        emit SignalPublished(id, hash, score);
    }

    function getSignal(uint256 id)
        external
        view
        returns (bytes32 hash, uint256 score, uint256 timestamp, address reporter)
    {
        Signal storage s = signals[id];
        return (s.hash, s.score, s.timestamp, s.reporter);
    }
}
