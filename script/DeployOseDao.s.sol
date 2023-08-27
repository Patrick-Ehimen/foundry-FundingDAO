// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import "forge-std/Script.sol";
import {OseDAO} from "../src/OseDAO.sol";

contract MyScript is Script {
    OseDAO public oseDaoContract;

    function run() public payable {
        oseDaoContract = new OseDAO();

        uint amount = msg.value;
        oseDaoContract.createStakeholderAndMember{value: amount}();
    }
}
