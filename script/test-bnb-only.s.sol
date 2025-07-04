// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../src/interfaces/IJoeDexLens.sol";

contract TestBNBOnly is Script {
    address constant JOEDEXLENS_PROXY = 0x8C7dc8184F5D78Aa40430b2d37f78fDC3e9A9b78;
    address constant WBNB = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;
    
    function run() external view {
        IJoeDexLens joeDexLens = IJoeDexLens(JOEDEXLENS_PROXY);
        
        console.log("=== Testing BNB Price Only (Fresh Data) ===");
        console.log("");
        
        // 测试 WBNB 价格查询
        console.log("Testing WBNB USD price:");
        uint256 wbnbPrice = joeDexLens.getTokenPriceUSD(WBNB);
        console.log("WBNB/USD Price:", wbnbPrice);
        
        console.log("Testing WBNB Native price:");
        uint256 wbnbNativePrice = joeDexLens.getTokenPriceNative(WBNB);
        console.log("WBNB/Native Price:", wbnbNativePrice);
        
        // 测试批量查询（只包含 WBNB）
        address[] memory tokens = new address[](1);
        tokens[0] = WBNB;
        
        console.log("Testing batch USD prices:");
        uint256[] memory usdPrices = joeDexLens.getTokensPricesUSD(tokens);
        console.log("Batch USD prices count:", usdPrices.length);
        if (usdPrices.length > 0) {
            console.log("WBNB USD Price (batch):", usdPrices[0]);
        }
        
        console.log("Testing batch Native prices:");
        uint256[] memory nativePrices = joeDexLens.getTokensPricesNative(tokens);
        console.log("Batch Native prices count:", nativePrices.length);
        if (nativePrices.length > 0) {
            console.log("WBNB Native Price (batch):", nativePrices[0]);
        }
    }
}
