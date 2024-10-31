
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {Test , console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundFundMe , WithdrawFundMe} from"../../script/Interactions.s.sol";


contract interactionsTest is Test{
    FundMe public fundMe;
    DeployFundMe deployFundMe;

    address alice=makeAddr("alice");
    uint256 public constant SEND_VALUE=0.1 ether;
    uint256 public constant STARTING_USER_BALANCE=10 ether;
    //uint256 constant GAS_PRICE=1;

    function setUp() external {
        deployFundMe = new DeployFundMe();
        (fundMe,) = deployFundMe.run();
        vm.deal(alice, STARTING_USER_BALANCE);
    }

    function testUserCanFundAndOwnerWithdraw() public {
        uint256 preUserBalance = address(alice).balance;
        uint256 preOwnerBalance = address(fundMe.getOwner()).balance;

        // Using vm.prank to simulate funding from the USER address
        vm.prank(alice);
        fundMe.fund{value: SEND_VALUE}();

        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        withdrawFundMe.withdrawFundMe(address(fundMe));

        uint256 afterUserBalance = address(alice).balance;
        uint256 afterOwnerBalance = address(fundMe.getOwner()).balance;

        assert(address(fundMe).balance == 0);
        assertEq(afterUserBalance + SEND_VALUE, preUserBalance);
        assertEq(preOwnerBalance + SEND_VALUE, afterOwnerBalance);
    }
}           