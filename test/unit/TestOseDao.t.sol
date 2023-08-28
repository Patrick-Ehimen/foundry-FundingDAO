// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import {OseDAO} from "../../src/OseDAO.sol";
import {Test, console} from "forge-std/Test.sol";

contract TestOseDao is Test {
    OseDAO public oseDaoContract;

    address public owner = makeAddr("owner");
    address public stakeHolder = makeAddr("stakeHolder");
    address public daoMember = makeAddr("daoMember1");
    address public nonMember = makeAddr("nonMember");
    address public receiverAddressForFunds =
        payable(makeAddr("receiverAddressForFunds"));

    uint public constant STARTING_BALANCE = 10 ether;
    uint public constant STARTING_DAO_BALANCE = 3000 ether;
    uint public constant MIN_DEPOSIT_VALUE = 1 ether;
    uint public constant DEPOSIT_VALUE = 2 ether;

    function setUp() public {
        // vm.startPrank(owner);
        oseDaoContract = new OseDAO();
        // vm.stopPrank();

        console.log("address of contract", address(oseDaoContract));
        console.log("address of owner", address(owner));

        vm.deal(daoMember, STARTING_BALANCE);
        vm.deal(nonMember, STARTING_BALANCE);
        vm.deal(stakeHolder, STARTING_BALANCE);
        vm.deal(address(oseDaoContract), STARTING_DAO_BALANCE);
    }

    /**
     * @dev Test creating a new stakeholder.
     * This function tests the creation of a new stakeholder and member by sending funds to the contract.
     * It verifies that the stakeholder and member roles are assigned correctly.
     * It also checks if the amount sent is greater than or equal to 2 ether, the stakeholder role is assigned.
     * @notice Remember to write a script to programmatically send funds.
     */
    function testCreateStakeHolder() public payable {
        uint256 amount = msg.value; //@audit remember to write script to programatically send funds

        // uint256 amount = 2 ether;

        vm.startPrank(nonMember);
        oseDaoContract.createStakeholderAndMember{value: amount}();
        assertTrue(oseDaoContract.hasRole(oseDaoContract.MEMBER(), nonMember));

        console.log("balance of newmember", oseDaoContract.getMemberBal());

        if (amount >= 2 ether) {
            assertTrue(
                oseDaoContract.hasRole(oseDaoContract.STAKEHOLDER(), nonMember)
            );
        } else {
            assertFalse(
                oseDaoContract.hasRole(oseDaoContract.STAKEHOLDER(), nonMember)
            );
        }

        console.log("is member", oseDaoContract.isMember());
        console.log("is stakeholder", oseDaoContract.isStakeHolder());

        if (amount == 0) revert("You can't send zero ether");

        // if (oseDaoContract.isMember() && oseDaoContract.isStakeHolder()) {
        //     assertGt(a, b);
        // }

        vm.stopPrank();
    }

    function testCreateProposalproposal() public {
        vm.startPrank(nonMember);

        oseDaoContract.createStakeholderAndMember{value: 2 ether}();
        string memory title = "New Proposal";
        string memory desc = "This is a new proposal";
        address receiverAddress = receiverAddressForFunds;
        uint256 amount = 30 ether;
        string memory imageId = "123";

        oseDaoContract.createProposal{value: 5e18}(
            title,
            desc,
            receiverAddress,
            amount,
            imageId
        );

        Proposal memory proposal = oseDaoContract.getProposal(0);

        assertEq(proposal.title, title);
        assertEq(proposal.description, description);
        assertEq(proposal.receiverAddress, receiver);
        assertEq(proposal.amount, amount);
        assertEq(proposal.imageId, imageId);

        vm.stopPrank();
    }

    //Test balance retrieval for stakeholders and members.
    function testRetrieveBalances() public {
        vm.prank(nonMember);
        testCreateStakeHolder();

        // Add more funds

        console.log(
            "get stakeholder balance",
            oseDaoContract.getStakeholderBal()
        );

        testCreateStakeHolder();
        console.log(
            "get stakeholder balance",
            oseDaoContract.getStakeholderBal()
        );
    }

    //Test adding funds to an existing stakeholder.
}
