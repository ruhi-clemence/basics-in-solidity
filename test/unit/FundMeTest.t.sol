
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {Test} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";


contract FundMeTest is Test{
    FundMe fundMe;
    address USER=makeAddr("user");
    uint256 constant SEND_VALUE=0.1 ether;
    uint256 constant STARTING_BALANCE=10 ether;
    uint256 constant GAS_PRICE=1;

    function setUp() external {
       
        DeployFundMe deployFundMe=new DeployFundMe();
        (fundMe,) = deployFundMe.run();
        vm.deal(USER,STARTING_BALANCE);
    }

    function testMinimumDollarIsFive()  public view{
        assertEq(fundMe.MINIMUM_USD(), 5E18);
        
    }

    function testOwnerIsMsgSender() public view{
assertEq(fundMe.getOwner(), msg.sender);
    }

    function testPriceFeedVersionIsAccurate() public view{
        uint256 version=fundMe.getVersion();
        assertEq(version,4);
    }
    function testFundFailsWithoutEnoughEth()public{
        vm.expectRevert();//thenext line should revert
        //assert(this test fails/reverts)
        fundMe.fund();//send 0 value
    }
    function testFundUpdatesFundedDataStructures() public{
        vm.prank(USER);//The next transaction will be sent by USER
        fundMe.fund{value:SEND_VALUE}();
        uint256 amountFunded=fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded,SEND_VALUE);

    }
    function testAddFunderToArrayOfFunders() public{
        vm.prank(USER);
        fundMe.fund{value:SEND_VALUE}();
        address funder=fundMe.getFunder(0);
        assertEq(funder,USER);
    }
    modifier funded(){
        vm.prank(USER);
        fundMe.fund{value:SEND_VALUE}();
        _;
    }
    function testOnlyOwnerCanWithdraw()public funded{
        vm.prank(USER);
        vm.expectRevert();
        fundMe.withdraw();
    }
    function testWithdrawWithASingleFunder()public funded{
        //arrange
        uint256 startingOwnerBalance=fundMe.getOwner().balance;
        uint256 startingFundMeBalance=address(fundMe).balance;
        //act
        vm.prank(fundMe.getOwner());
        fundMe.withdraw(); 
        //assert
        uint256 endingOwnerBalance=fundMe.getOwner().balance;
        uint256 endingFundMeBalance=address(fundMe).balance;
        assertEq(endingOwnerBalance,startingOwnerBalance+startingFundMeBalance);
        assertEq(endingFundMeBalance,0);
    }
    function testWithdrawFromMultipleFunders()public funded{
        //ARRANGE
        uint160 numberofFunders=10;//want to use numbers to generate addresses uint160 same bytecodes as addreses
        uint160 startingFunderIndex=1;
        for(uint160 i=startingFunderIndex;i<numberofFunders;i++){
            //vm.prank new address
            //vm.deal new address
            //address()
            hoax(address(uint160(i)),1 ether);
            fundMe.fund{value:SEND_VALUE}();
        }
        uint256 startingOwnerBalance=fundMe.getOwner().balance;
        uint256 startingFundMeBalance=address(fundMe).balance;
        //ACT
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();
        //ASSERT
        assert(address(fundMe).balance==0);
        assert(startingFundMeBalance+startingOwnerBalance==fundMe.getOwner().balance);
    }
    function testWithdrawFromMultipleFundersCheaper()public funded{
        //ARRANGE
        uint160 numberofFunders=10;//want to use numbers to generate addresses uint160 same bytecodes as addreses
        uint160 startingFunderIndex=1;
        for(uint160 i=startingFunderIndex;i<numberofFunders;i++){
            //vm.prank new address
            //vm.deal new address
            //address()
            hoax(address(uint160(i)),1 ether);
            fundMe.fund{value:SEND_VALUE}();
        }
        uint256 startingOwnerBalance=fundMe.getOwner().balance;
        uint256 startingFundMeBalance=address(fundMe).balance;
        //ACT
        vm.startPrank(fundMe.getOwner());
        fundMe.cheaperWithdraw();
        vm.stopPrank();
        //ASSERT
        assert(address(fundMe).balance==0);
        assert(startingFundMeBalance+startingOwnerBalance==fundMe.getOwner().balance);
    }
}
