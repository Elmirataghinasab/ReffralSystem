// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;


import {Token} from "../src/token.sol";
import {Test, console} from "forge-std/Test.sol";
import {StdCheats} from "forge-std/StdCheats.sol";
import {RefferalSystem} from "../src/refferalContract.sol";
import {refScript} from "../script/contract.s.sol";



contract RefferalSystemTest is Test{

    refScript deploy;
    Token MyToken;
    RefferalSystem refferalSystem;

    address user1=address(2);
    address user2=address(3);
    address user3=address(4);
    address user4=address(5);
    address user5=address(6);
    address Owner;
    uint256 initialSupply=100e18;
    uint256 decimal;


    function setUp()public{
        deploy= new refScript();
        MyToken=deploy.runToken(initialSupply);
        refferalSystem=deploy.runSystem(address(MyToken));
        Owner=refferalSystem.GetOwner();
        decimal=refferalSystem.GetDecimal();

    }



    function testParticipateCorrectly()public{

        vm.prank(Owner);
        MyToken.transfer(user1, 30*decimal); 
        vm.startPrank(user1);  
        MyToken.approve(address(refferalSystem),30*decimal);          
        refferalSystem.participate(Owner,30);
        vm.stopPrank();


        assertEq(MyToken.balanceOf(user1), 0);
        assertEq(MyToken.balanceOf(Owner),100*decimal);
        
    }



    function testParticipateWith2SubsetsCorrectly() public{

        vm.startPrank(Owner);
        MyToken.transfer(user3, 30*decimal); 
        MyToken.transfer(user2,30*decimal);
        MyToken.transfer(user1, 30*decimal); 
        vm.stopPrank();
        vm.startPrank(user1);  
        MyToken.approve(address(refferalSystem),30*decimal);                  
        refferalSystem.participate(Owner,30);
        vm.stopPrank();
        vm.startPrank(user2);  
        MyToken.approve(address(refferalSystem),30*decimal);                  
        refferalSystem.participate(Owner,30);
        vm.stopPrank();

        assertEq(MyToken.balanceOf(user2), 0);
        assertEq(MyToken.balanceOf(user1), 0);
        assertEq(MyToken.balanceOf(Owner),70*decimal);

    }


    function testThirdStraightSubsetFails()public{

        vm.startPrank(Owner);
        MyToken.transfer(user2,30*decimal);
        MyToken.transfer(user1, 30*decimal); 
        MyToken.transfer(user3,30*decimal);
        vm.stopPrank();
        vm.startPrank(user1);  
        MyToken.approve(address(refferalSystem),30*decimal);                  
        refferalSystem.participate(Owner,30);
        vm.stopPrank();
        vm.startPrank(user2);  
        MyToken.approve(address(refferalSystem),30*decimal);                  
        refferalSystem.participate(Owner,30);
        vm.stopPrank();
        vm.startPrank(user3);  
        MyToken.approve(address(refferalSystem),30*decimal); 
        vm.expectRevert(RefferalSystem.ReferralSystem_MaximumSubsetsReached.selector);
        refferalSystem.participate(Owner,30);
        vm.stopPrank();
    }

    function testIfUpperLinesgetPaid()public{

        vm.startPrank(Owner);
        MyToken.transfer(user2,30*decimal);
        MyToken.transfer(user1, 30*decimal); 
        MyToken.transfer(user3,30*decimal);
        vm.stopPrank();
        vm.startPrank(user1);  
        MyToken.approve(address(refferalSystem),30*decimal);                  
        refferalSystem.participate(Owner,30);
        vm.stopPrank();
        vm.startPrank(user2);  
        MyToken.approve(address(refferalSystem),30*decimal);                  
        refferalSystem.participate(user1,30);
        vm.stopPrank();
        vm.startPrank(user3);  
        MyToken.approve(address(refferalSystem),30*decimal); 
        refferalSystem.participate(user2,30);
        vm.stopPrank();


        assertEq(MyToken.balanceOf(user3), 0);
        assertEq(MyToken.balanceOf(user2), 3*decimal);
        assertEq(MyToken.balanceOf(user1), (15e17)+(3*decimal));
        assertEq(MyToken.balanceOf(Owner),925e17 );

    }

    function testParticipateConditions()public{

        vm.startPrank(address(0));
        vm.expectRevert(RefferalSystem.ReferralSystem_YouCantParticipateWithAddress0.selector);
        refferalSystem.participate(Owner,10);
        vm.stopPrank();


        vm.startPrank(Owner);
        MyToken.transfer(user1, 60*decimal);
        MyToken.transfer(user1, 20*decimal);  
        vm.stopPrank();
        vm.startPrank(user1);
        MyToken.approve(address(refferalSystem),30*decimal); 
        vm.expectRevert(RefferalSystem.ReferralSystem_YouCannotEnterWithoutReferralId.selector);                 
        refferalSystem.participate(address(0),30);
        vm.stopPrank();


        vm.startPrank(user1);
        MyToken.approve(address(refferalSystem),90*decimal);                 
        refferalSystem.participate(Owner,30);
        vm.expectRevert(RefferalSystem.ReferralSystem_YouHaveParticipatedBefore.selector);
        refferalSystem.participate(Owner,30);
        vm.stopPrank();


        vm.startPrank(user3);
        MyToken.approve(address(refferalSystem),5*decimal); 
        vm.expectRevert(RefferalSystem.ReferralSystem_PleaseSendMoreToken.selector);                 
        refferalSystem.participate(Owner,5);
        vm.stopPrank();

        vm.startPrank(user2);
        MyToken.approve(address(refferalSystem),20*decimal);                 
        vm.expectRevert(RefferalSystem.ReferralSystem_YourReferralIdIsWrong.selector);
        refferalSystem.participate(user3,30);
        vm.stopPrank();
    }


    
    



}