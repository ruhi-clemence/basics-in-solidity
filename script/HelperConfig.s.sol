//SPDX-License-Identifier:MIT
pragma solidity ^0.8.27;

//1.deploy mocks when we are on an anvil chain
//keep track of contract address across different chains
//sepolia ETH/USD
//mainnet ETH/USD


import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script{

    NetworkConfig public activeNetworkConfig;
    uint8 public constant DECIMALS=8;
    int256 public constant INITIAL_PRICE=2000e8;


    struct NetworkConfig {
        address priceFeed;//ETH/USD PRICE FEED ADDRESS
    }

    constructor(){
        if(block.chainid==11155111){//sepolia chain id
            activeNetworkConfig=getSepoliaEthconfig();
        }else if(block.chainid==1){
            activeNetworkConfig=getMainnetEthConfig();
        }else{
            activeNetworkConfig=getorCreateAnvilEthConfig();
        }
    }
    //If we are on a local chain, we deploy mocks
    //otherwise, we use the existing deployed mock

    function getSepoliaEthconfig() public pure returns(NetworkConfig memory){
        //pricefeed address
        NetworkConfig memory sepoliaConfig=NetworkConfig({
            priceFeed:0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
        return sepoliaConfig;
    }

    function getMainnetEthConfig()public pure returns(NetworkConfig memory){
        //pricefeed address
        NetworkConfig memory ethConfig=NetworkConfig({
            priceFeed:0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
        });
        return ethConfig;
    }

    function getorCreateAnvilEthConfig()public returns(NetworkConfig memory){
        if (activeNetworkConfig.priceFeed!=address(0)){
            return activeNetworkConfig;
        }
        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed= new MockV3Aggregator(DECIMALS, INITIAL_PRICE);
        vm.stopBroadcast();
        NetworkConfig memory anvilConfig=NetworkConfig({
            priceFeed:address(mockPriceFeed)
        });
        return anvilConfig;
        
        }
    }















