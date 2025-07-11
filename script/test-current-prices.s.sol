// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../src/interfaces/IJoeDexLens.sol";

contract TestCurrentPrices is Script {
    // 已部署的DexLens合约地址
    address constant JOEDEXLENS_PROXY = 0x8C7dc8184F5D78Aa40430b2d37f78fDC3e9A9b78;

    // 测试代币地址
    address constant WBNB = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd; 
    address constant USDC = 0x64544969ed7EBf5f083679233325356EbE738930; 

    function run() external view {
        console.log("=== Testing Current DexLens Prices ===");
        console.log("DexLens Address:", JOEDEXLENS_PROXY);
        console.log("");

        IJoeDexLens joeDexLens = IJoeDexLens(JOEDEXLENS_PROXY);

        // Test WBNB price
        uint256 wbnbPriceUSD = joeDexLens.getTokenPriceUSD(WBNB);
        uint256 wbnbPriceNative = joeDexLens.getTokenPriceNative(WBNB);
        
        console.log("WBNB:");
        console.log("  Price USD (raw):", wbnbPriceUSD);
        console.log("  Price USD (formatted):", wbnbPriceUSD / 1e18);
        console.log("  Price Native (raw):", wbnbPriceNative);
        console.log("  Price Native (formatted):", wbnbPriceNative / 1e18);
        console.log("");

        // Test USDC price
        uint256 usdcPriceUSD = joeDexLens.getTokenPriceUSD(USDC);
        uint256 usdcPriceNative = joeDexLens.getTokenPriceNative(USDC);
        
        console.log("USDC:");
        console.log("  Price USD (raw):", usdcPriceUSD);
        console.log("  Price USD (formatted):", usdcPriceUSD / 1e18);
        console.log("  Price Native (raw):", usdcPriceNative);
        console.log("  Price Native (formatted):", usdcPriceNative / 1e18);
        console.log("");

        // Calculate expected USDC/WBNB ratio
        if (usdcPriceUSD > 0 && wbnbPriceUSD > 0) {
            uint256 ratio = (usdcPriceUSD * 1e18) / wbnbPriceUSD;
            console.log("USDC/WBNB ratio:", ratio / 1e15, "per 1000");
        }
    }
}
