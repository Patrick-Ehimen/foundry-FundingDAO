// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";

// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

/**
 * @title OseDAO
 * @dev OseDAO is a decentralized autonomous organization that allows members to create and vote on proposals.
 * @author [Ose]
 */
contract OseDAO is ReentrancyGuard, AccessControl {
    // Define role constants for member and stakeholder
    bytes32 public constant MEMBER = keccak256("MEMBER");
    bytes32 public constant STAKEHOLDER = keccak256("STAKEHOLDER");

    // Define the duration of the voting period
    uint constant votingPeriod = 5 days;
    // Keep track of the number of proposals
    uint public proposalsCount;

    /**
     * @dev Represents a proposal in the OseDAO.
     */
    struct Proposal {
        uint256 id; //ID of the proposal
        uint256 amount; //amount of funds requested
        uint256 livePeriod; //duration of the proposal
        uint256 voteInFavour; //number of votes in favor of the proposal
        uint256 voteAgainst; //number of votes against the proposal
        string title; //title of the proposal
        string description; //description of the proposal
        bool isCompleted; //Indicates whether the proposal is completed
        bool paid; //Indicates whether the proposal is paid
        bool isPaid; //Indicates whether the proposal is paid
        address payable receiverAddress; //Address of the receiver of funds for the proposal
        address proposer; //Address of the proposer of the proposal
        uint256 totalFundRaised; //total funds raised for the proposal
        Funding[] funders; //Array of funders who contributed to the proposal
        string imageId; //ID of the image associated with the proposal
    }

    /**
     * @dev Represents a funding for a proposal.
     */
    struct Funding {
        address payer; // Address of the payer
        uint amount; // Amount of funds contributed
        uint timeStamp; // Timestamp of the contribution
    }

    // Mapping of proposal ID to Proposal struct
    mapping(uint256 => Proposal) private proposals;
    // Mapping of stakeholder address to stakeholder balance
    mapping(address => uint256) private stakeHolders;
    // Mapping of member address to member balance
    mapping(address => uint256) private members;
    // Mapping of address to array of votes
    mapping(address => uint256[]) private votes;

    event NewMember(address indexed fromAddress, uint256 amount);
    event NewProposal(address indexed proposer, uint256 amount);
    event Payment(
        address indexed stakeholder,
        address indexed projectAddress,
        uint256 amount
    );

    /**
     * @dev Modifier to check if the caller is a member.
     * @param message Error message to display if the caller is not a member
     */
    modifier onlyMember(string memory message) {
        require(hasRole(MEMBER, msg.sender), message);
        _;
    }

    /**
     * @dev Modifier to check if the caller is a stakeholder.
     * @param message Error message to display if the caller is not a stakeholder
     */
    modifier onlyStakeholder(string memory message) {
        require(hasRole(STAKEHOLDER, msg.sender), message);
        _;
    }

    /**
     * @dev Creates a new proposal in the OseDAO.
     * @param title Title of the proposal
     * @param desc Description of the proposal
     * @param receiverAddress Address of the receiver of funds
     * @param amount Amount of funds requested
     * @param imageId ID of the image associated with the proposal
     */
    function createProposal(
        string calldata title,
        string calldata desc,
        address receiverAddress,
        uint256 amount,
        string calldata imageId
    ) public payable onlyMember("Only members can create new proposal.") {
        require(
            msg.value == 5e18,
            "You need to add 5 MATIC to create a proposal"
        );
        uint256 proposalId = proposalsCount;
        Proposal storage proposal = proposals[proposalId];
        proposal.id = proposalId;
        proposal.description = desc;
        proposal.title = title;
        proposal.receiverAddress = payable(receiverAddress);
        proposal.proposer = payable(msg.sender);
        proposal.amount = amount;
        proposal.livePeriod = block.timestamp + votingPeriod;
        proposal.isPaid = false;
        proposal.isCompleted = false;
        proposal.imageId = imageId;
        proposalsCount++;
        emit NewProposal(msg.sender, amount);
    }

    /**
     * @dev Retrieves all proposals in the OseDAO.
     * @return An array of Proposal structs representing all proposals
     */
    function getAllProposals() public view returns (Proposal[] memory) {
        Proposal[] memory temProposals = new Proposal[](proposalsCount);
        for (uint256 i = 0; i < proposalsCount; i++) {
            temProposals[i] = proposals[i];
        }
        return temProposals;
    }

    /**
     * @dev Retrieves a specific proposal in the OseDAO.
     * @param proposalId ID of the proposal to retrieve
     * @return The Proposal struct representing the specified proposal
     */
    function getProposal(
        uint256 proposalId
    ) public view returns (Proposal memory) {
        return proposals[proposalId];
    }

    /**
     * @dev Retrieves the votes of the caller who is a stakeholder.
     * @return An array of vote IDs representing the votes of the caller who is a stakeholder
     */
    function getVotes()
        public
        view
        onlyStakeholder("Only Stakeholder can call this function.")
        returns (uint256[] memory)
    {
        return votes[msg.sender];
    }

    /**
     * @dev Retrieves the balance of the caller who is a stakeholder.
     * @return The balance of the caller who is a stakeholder
     */
    function getStakeholderBal()
        public
        view
        onlyStakeholder("Only Stakeholder can call this function.")
        returns (uint256)
    {
        return stakeHolders[msg.sender];
    }

    /**
     * @dev Retrieves the balance of the caller who is a member.
     * @return The balance of the caller who is a member
     */
    function getMemberBal()
        public
        view
        onlyMember("Only Members can call this function")
        returns (uint256)
    {
        return members[msg.sender];
    }

    /**
     * @dev Checks if the caller is a stakeholder.
     * @return True if the caller is a stakeholder, false otherwise
     */
    function isStakeHolder() public view returns (bool) {
        return stakeHolders[msg.sender] > 0;
    }

    /**
     * @dev Checks if the caller is a member.
     * @return True if the caller is a member, false otherwise
     */
    function isMember() public view returns (bool) {
        return members[msg.sender] > 0;
    }

    /**
     * @dev Allows a stakeholder to vote on a proposal.
     * @param proposalId ID of the proposal to vote on
     * @param inFavour Boolean indicating whether the vote is in favour or against the proposal
     */
    function vote(
        uint256 proposalId,
        bool inFavour
    ) public onlyStakeholder("Only Stakeholders can vote on a proposal.") {
        Proposal storage proposal = proposals[proposalId];

        // Check if the proposal is completed or the live period has ended
        if (proposal.isCompleted || proposal.livePeriod <= block.timestamp) {
            proposal.isCompleted = true;
            revert("Time period of this proposal is ended.");
        }

        // Check if the stakeholder has already voted on this proposal
        for (uint256 i = 0; i < votes[msg.sender].length; i++) {
            if (proposal.id == votes[msg.sender][i])
                revert("You can only vote once.");
        }

        // Increment the vote count based on the vote type
        if (inFavour) proposal.voteInFavour++;
        else proposal.voteAgainst++;

        // Add the proposal ID to the stakeholder's votes
        votes[msg.sender].push(proposalId);
    }

    /**
     * @dev Provides funds for a proposal.
     * @param proposalId ID of the proposal to provide funds for
     * @param fundAmount Amount of funds to provide
     */
    function providefunds(
        uint256 proposalId,
        uint256 fundAmount
    ) public payable onlyStakeholder("Only stakeholders can make payments") {
        Proposal storage proposal = proposals[proposalId];

        // Check if the proposal has already been paid
        if (proposal.isPaid) revert("Required funds are already provided");

        // Check if the proposal has enough votes in favor
        if (proposal.voteInFavour <= proposal.voteAgainst)
            revert("This proposal is not selected for funding.");

        // Check if the required funds have already been provided
        if (proposal.totalFundRaised >= proposal.amount)
            revert("Required funds are already provided.");

        // Add the provided funds to the total fund raised for the proposal
        proposal.totalFundRaised += fundAmount;

        // Add the funder to the list of funders for the proposal
        proposal.funders.push(Funding(msg.sender, fundAmount, block.timestamp));

        // Check if the total fund raised is equal to or greater than the required amount
        if (proposal.totalFundRaised >= proposal.amount) {
            proposal.isCompleted = true;
        }
    }

    /**
     * @dev Releases funding for a proposal.
     * @param proposalId ID of the proposal to release funds for
     */
    function releaseFunding(
        uint256 proposalId
    )
        public
        payable
        onlyStakeholder("Only Stakeholders are allowed to release funds")
    {
        Proposal storage proposal = proposals[proposalId];

        // Check if the required funds have been met
        if (proposal.totalFundRaised <= proposal.amount) {
            revert("Required funds are not met. Please provide funds.");
        }
        proposal.receiverAddress.transfer(proposal.totalFundRaised);
        proposal.isPaid = true;
        proposal.isCompleted = true;
    }

    /**
     * @dev Creates a new stakeholder in the OseDAO.
     * @notice This function allows a user to become a stakeholder by depositing a certain amount of funds.
     * @notice If the user is already a stakeholder, the deposited funds will be added to their existing stake.
     * @notice If the user's total stake (including the deposited funds) is equal to or greater than 2 ether, they will also become a member.
     */
    function createStakeholder() public payable {
        uint256 amount = msg.value;
        // Check if the sender is not already a stakeholder
        if (!hasRole(STAKEHOLDER, msg.sender)) {
            uint256 total = members[msg.sender] + amount;
            // Check if the total stake (including the deposited funds) is equal to or greater than 2 ether
            if (total >= 2 ether) {
                _setupRole(STAKEHOLDER, msg.sender);
                _setupRole(MEMBER, msg.sender);
                stakeHolders[msg.sender] = total;
                members[msg.sender] += amount;
            } else {
                _setupRole(MEMBER, msg.sender);
                members[msg.sender] += amount;
            }
        } else {
            members[msg.sender] += amount;
            stakeHolders[msg.sender] += amount;
        }
    }
}
