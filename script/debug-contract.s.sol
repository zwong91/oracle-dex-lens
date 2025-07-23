// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../src/interfaces/IJoeDexLens.sol";

contract DebugContract is Script {
    // 已部署的代理合约地址
    address constant JOEDEXLENS_PROXY = 0xb512457fcB3020dC4a62480925B68dc83E776340;
    
    // BSC测试网上的代币地址
    address constant WBNB = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;
    address constant USDC = 0x64544969ed7EBf5f083679233325356EbE738930;
    address constant USDT = 0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684;
    
    function run() external view {
        IJoeDexLens joeDexLens = IJoeDexLens(JOEDEXLENS_PROXY);
        
        console.log("=== Direct Contract Debug ===");
        console.log("Contract Address:", JOEDEXLENS_PROXY);
        console.log("");
        
        console.log("Testing getWNative():");
        address wNative = joeDexLens.getWNative();
        console.log("WNative:", wNative);
        console.log("");
        
        console.log("Testing getDataFeeds for WBNB:");
        IJoeDexLens.DataFeed[] memory wbnbFeeds = joeDexLens.getDataFeeds(WBNB);
        console.log("WBNB feeds count:", wbnbFeeds.length);
        for (uint i = 0; i < wbnbFeeds.length; i++) {
            console.log("Feed", i, ":");
            console.log("  dfAddress:", wbnbFeeds[i].dfAddress);
            console.log("  dfType:", uint256(wbnbFeeds[i].dfType));
            console.log("  dfWeight:", wbnbFeeds[i].dfWeight);
            console.log("  collateralAddress:", wbnbFeeds[i].collateralAddress);
        }
        console.log("");
        
        console.log("Testing getDataFeeds for USDC:");
        IJoeDexLens.DataFeed[] memory usdcFeeds = joeDexLens.getDataFeeds(USDC);
        console.log("USDC feeds count:", usdcFeeds.length);
        for (uint i = 0; i < usdcFeeds.length; i++) {
            console.log("Feed", i, ":");
            console.log("  dfAddress:", usdcFeeds[i].dfAddress);
            console.log("  dfType:", uint256(usdcFeeds[i].dfType));
            console.log("  dfWeight:", usdcFeeds[i].dfWeight);
            console.log("  collateralAddress:", usdcFeeds[i].collateralAddress);
        }
        console.log("");
        
        console.log("Testing getDataFeeds for USDT:");
        IJoeDexLens.DataFeed[] memory usdtFeeds = joeDexLens.getDataFeeds(USDT);
        console.log("USDT feeds count:", usdtFeeds.length);
        for (uint i = 0; i < usdtFeeds.length; i++) {
            console.log("Feed", i, ":");
            console.log("  dfAddress:", usdtFeeds[i].dfAddress);
            console.log("  dfType:", uint256(usdtFeeds[i].dfType));
            console.log("  dfWeight:", usdtFeeds[i].dfWeight);
            console.log("  collateralAddress:", usdtFeeds[i].collateralAddress);
        }
        console.log("");
        
        // 测试价格查询
        console.log("Testing price queries:");
        uint256 wbnbPriceUSD = joeDexLens.getTokenPriceUSD(WBNB);
        console.log("WBNB USD Price:", wbnbPriceUSD);
        
        uint256 usdcPriceUSD = joeDexLens.getTokenPriceUSD(USDC);
        console.log("USDC USD Price:", usdcPriceUSD);
        
        uint256 usdtPriceUSD = joeDexLens.getTokenPriceUSD(USDT);
        console.log("USDT USD Price:", usdtPriceUSD);
    }
}
