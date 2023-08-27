// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import {OseDAO} from "../../src/OseDAO.sol";
import {Test, console} from "forge-std/Test.sol";

contract TestOseDao is Test {
    OseDAO public oseDaoContract;
    address 

    function setUp() public {
        oseDaoContract = new OseDAO();
        
        address USER = makeAddr("user"); 
    }
}
