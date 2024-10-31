//SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {Script} from "forge-std/Script.sol";
import{FundMe} from"../src/FundMe.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployFundMe is Script {
    function run() external returns(FundMe,HelperConfig){
        //before startBroadcast ->not a real transaction
        HelperConfig helperConfig=new HelperConfig();
        address ethUsdPriceFeed=helperConfig.activeNetworkConfig();

        // afterstartBroadcast ->real transaction
        vm.startBroadcast();
        FundMe fundMe = new FundMe(ethUsdPriceFeed);
        vm.stopBroadcast();
        return (fundMe,helperConfig);
    }
}