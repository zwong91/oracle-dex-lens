// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../src/interfaces/IJoeDexLens.sol";

contract CallJoeDexLens is Script {
    address constant JOEDEXLENS_PROXY = 0xE47Fe3F5e9853582104bF0d9d086A803575A9FB9;
    address constant WBNB = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;
    address constant USDC = 0x64544969ed7EBf5f083679233325356EbE738930;
    address constant USDT = 0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684;
    
    function run() external view {
        IJoeDexLens joeDexLens = IJoeDexLens(JOEDEXLENS_PROXY);
        
        console.log("=== JoeDexLens Test ===");
        console.log("Contract:", JOEDEXLENS_PROXY);
        console.log("");
        
        testBasicInfo(joeDexLens);
        testPrices(joeDexLens);
        testDataFeeds(joeDexLens);
        
        console.log("=== Test Completed ===");
    }
    
    function testBasicInfo(IJoeDexLens joeDexLens) internal view {
        console.log("1. Basic Info:");
        address wNative = joeDexLens.getWNative();
        console.log("   WNative:", wNative);
        console.log("");
    }
    
    function testPrices(IJoeDexLens joeDexLens) internal view {
        console.log("2. Price Queries:");
        
        // WBNB prices
        uint256 wbnbNative = joeDexLens.getTokenPriceNative(WBNB);
        uint256 wbnbUSD = joeDexLens.getTokenPriceUSD(WBNB);
        console.log("   WBNB Native:", wbnbNative);
        console.log("   WBNB USD:", wbnbUSD);
        
        // USDC prices
        uint256 usdcNative = joeDexLens.getTokenPriceNative(USDC);
        uint256 usdcUSD = joeDexLens.getTokenPriceUSD(USDC);
        console.log("   USDC Native:", usdcNative);
        console.log("   USDC USD:", usdcUSD);
        
        // USDT prices
        uint256 usdtNative = joeDexLens.getTokenPriceNative(USDT);
        uint256 usdtUSD = joeDexLens.getTokenPriceUSD(USDT);
        console.log("   USDT Native:", usdtNative);
        console.log("   USDT USD:", usdtUSD);
        
        console.log("");
    }
    
    function testDataFeeds(IJoeDexLens joeDexLens) internal view {
        console.log("3. Data Feeds:");
        
        // WBNB data feeds
        IJoeDexLens.DataFeed[] memory wbnbFeeds = joeDexLens.getDataFeeds(WBNB);
        console.log("   WBNB feeds:", wbnbFeeds.length);
        
        // USDC data feeds
        IJoeDexLens.DataFeed[] memory usdcFeeds = joeDexLens.getDataFeeds(USDC);
        console.log("   USDC feeds:", usdcFeeds.length);
        
        // USDT data feeds
        IJoeDexLens.DataFeed[] memory usdtFeeds = joeDexLens.getDataFeeds(USDT);
        console.log("   USDT feeds:", usdtFeeds.length);
        
        console.log("");
    }
}
