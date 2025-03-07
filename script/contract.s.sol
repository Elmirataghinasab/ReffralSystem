// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import {Script, console} from "forge-std/Script.sol";
import {Token} from "../src/token.sol";
import {RefferalSystem} from "../src/refferalContract.sol";



contract refScript is Script{
 
    function runToken(uint256 initialSupply)external returns (Token){
        vm.startBroadcast();
        Token token = new Token(initialSupply);
        vm.stopBroadcast();

        return token;
    }


    function runSystem(address tokenAddress)external returns(RefferalSystem){
        vm.startBroadcast();
        RefferalSystem refferalsystem=new RefferalSystem(tokenAddress);
        vm.stopBroadcast();

        return refferalsystem;
    }



}