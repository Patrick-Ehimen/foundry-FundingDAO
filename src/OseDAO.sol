// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract OseDAO is ReentrancyGuard, AccessControl {
    bytes32 public constant MEMBER = keccak256("MEMBER");
    bytes32 public constant STAKEHOLDER = keccak256("STAKEHOLDER");

    uint constant votingPeriod = 5 days;
    uint public proposalCount;

    struct Proposal {
        uint256 id;
        uint256 amount;
        uint256 livePeriod;
        uint256 voteInFavour;
        uint256 voteAgainst;
        string title;
        string desciption;
        bool isCompleted;
        bool paid;
        bool isPaid;
        address payable receiverAddress;
    }
}
