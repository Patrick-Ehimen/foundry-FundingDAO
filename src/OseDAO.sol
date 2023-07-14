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
        address proposer;
        uint256 totalFundRaised;
        Funding[] funders;
        string imageId;
    }

    struct Funding {
        address payer;
        uint amount;
        uint timeStamp;
    }

    mapping(uint256 => Proposal) private proposals;
    mapping(address => uint256) private stakeHolders;
    mapping(address => uint256) private members;
    mapping(address => uint256[]) private votes;

    event NewMember(address indexed fromAddress, uint256 amount);
    event NewProposal(address indexed proposer, uint256 amount);
    event Payment(
        address indexed stakeholder,
        address indexed projectAddress,
        uint256 amount
    );
}
