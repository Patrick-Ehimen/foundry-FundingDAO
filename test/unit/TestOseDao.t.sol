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
    uint public constant STARTING_DAO_BALANCE = 1000 ether;

    function setUp() public {
        vm.startPrank(owner);
        oseDaoContract = new OseDAO();
        vm.stopPrank();

        console.log("address of contract", address(oseDaoContract));
        console.log("address of owner", address(owner));

        vm.deal(daoMember, STARTING_BALANCE);
        vm.deal(nonMember, STARTING_BALANCE);
        vm.deal(stakeHolder, STARTING_BALANCE);
        vm.deal(address(oseDaoContract), STARTING_DAO_BALANCE);
    }

    function testCreateStakeHolderAndMember() public {
        //Deposit greater than 2 ETH
        vm.prank(nonMember);
        oseDaoContract.createStakeholderAndMember{value: 2 ether}();

        assertTrue(
            oseDaoContract.hasRole(oseDaoContract.STAKEHOLDER(), nonMember)
        );
        assertTrue(oseDaoContract.hasRole(oseDaoContract.MEMBER(), nonMember));
        assertEq(oseDaoContract.getStakeholderBal(), )
    }

    // function testCreateProposal() public {
    //     string memory title = "New Proposal";
    //     string memory desc = "This is a new proposal";
    //     address receiverAddress = receiverAddressForFunds;
    //     uint256 amount = 100;
    //     string memory imageId = "123";
    // }
}
