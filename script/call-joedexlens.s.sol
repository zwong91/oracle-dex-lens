// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../src/interfaces/IJoeDexLens.sol";

contract CallJoeDexLens is Script {
    // 已部署的代理合约地址（调用的主合约地址）
    address constant JOEDEXLENS_PROXY = 0x8C7dc8184F5D78Aa40430b2d37f78fDC3e9A9b78;
    
    // BSC测试网上的一些常见代币地址
    address constant WBNB = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd; // BSC测试网 WBNB
    address constant USDC = 0x64544969ed7EBf5f083679233325356EbE738930; // BSC测试网 USDC
    address constant USDT = 0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684; // BSC测试网 USDT
    
    function run() external view {
        IJoeDexLens joeDexLens = IJoeDexLens(JOEDEXLENS_PROXY);
        
        console.log("=== JoeDexLens Contract Call Example ===");
        console.log("Contract Address:", JOEDEXLENS_PROXY);
        console.log("");
        
        callGetDataFeeds(joeDexLens);
        callGetWNative(joeDexLens);
        callGetTokenPriceNative(joeDexLens);
        callGetTokenPriceUSD(joeDexLens);
        callGetTokensPricesNative(joeDexLens);
        callGetTokensPricesUSD(joeDexLens);
    }
    
    function callGetWNative(IJoeDexLens joeDexLens) internal view {
        console.log("1. Get WNative Address:");
        address wNative = joeDexLens.getWNative();
        console.log("   WNative Address:", wNative);
        console.log("");
    }
    
    function callGetDataFeeds(IJoeDexLens joeDexLens) internal view {
        console.log("0. Check Data Feeds Configuration:");
        
        // Check WBNB data feeds
        try joeDexLens.getDataFeeds(WBNB) returns (IJoeDexLens.DataFeed[] memory dataFeeds) {
            console.log("   WBNB Data Feeds Count:", dataFeeds.length);
            for (uint i = 0; i < dataFeeds.length; i++) {
                console.log("   DataFeed", i, "- Address:", dataFeeds[i].dfAddress);
                console.log("   DataFeed", i, "- Type:", uint256(dataFeeds[i].dfType));
                console.log("   DataFeed", i, "- Weight:", dataFeeds[i].dfWeight);
                console.log("   DataFeed", i, "- Collateral:", dataFeeds[i].collateralAddress);
            }
        } catch Error(string memory reason) {
            console.log("   WBNB: Error -", reason);
        } catch {
            console.log("   WBNB: No data feeds configured");
        }
        
        // Check USDC data feeds
        try joeDexLens.getDataFeeds(USDC) returns (IJoeDexLens.DataFeed[] memory dataFeeds) {
            console.log("   USDC Data Feeds Count:", dataFeeds.length);
            for (uint i = 0; i < dataFeeds.length; i++) {
                console.log("   DataFeed", i, "- Address:", dataFeeds[i].dfAddress);
                console.log("   DataFeed", i, "- Type:", uint256(dataFeeds[i].dfType));
                console.log("   DataFeed", i, "- Weight:", dataFeeds[i].dfWeight);
            }
        } catch Error(string memory reason) {
            console.log("   USDC: Error -", reason);
        } catch {
            console.log("   USDC: No data feeds configured");
        }
        
        // Check USDT data feeds
        try joeDexLens.getDataFeeds(USDT) returns (IJoeDexLens.DataFeed[] memory dataFeeds) {
            console.log("   USDT Data Feeds Count:", dataFeeds.length);
            for (uint i = 0; i < dataFeeds.length; i++) {
                console.log("   DataFeed", i, "- Address:", dataFeeds[i].dfAddress);
                console.log("   DataFeed", i, "- Type:", uint256(dataFeeds[i].dfType));
                console.log("   DataFeed", i, "- Weight:", dataFeeds[i].dfWeight);
            }
        } catch Error(string memory reason) {
            console.log("   USDT: Error -", reason);
        } catch {
            console.log("   USDT: No data feeds configured");
        }
        console.log("");
    }
    
    function callGetTokenPriceNative(IJoeDexLens joeDexLens) internal view {
        console.log("2. Get Token Price in Native:");
        
        // Get WBNB Native price (should be 1)
        try joeDexLens.getTokenPriceNative(WBNB) returns (uint256 price) {
            console.log("   WBNB/Native Price:", price);
        } catch Error(string memory reason) {
            console.log("   WBNB/Native Price: Error -", reason);
        } catch {
            console.log("   WBNB/Native Price: Failed - No data feeds or price unavailable");
        }
        
        // Try to get other tokens' Native prices
        try joeDexLens.getTokenPriceNative(USDC) returns (uint256 price) {
            console.log("   USDC/Native Price:", price);
        } catch Error(string memory reason) {
            console.log("   USDC/Native Price: Error -", reason);
        } catch {
            console.log("   USDC/Native Price: Failed");
        }
        
        try joeDexLens.getTokenPriceNative(USDT) returns (uint256 price) {
            console.log("   USDT/Native Price:", price);
        } catch Error(string memory reason) {
            console.log("   USDT/Native Price: Error -", reason);
        } catch {
            console.log("   USDT/Native Price: Failed");
        }
        console.log("");
    }
    
    function callGetTokenPriceUSD(IJoeDexLens joeDexLens) internal view {
        console.log("3. Get Token Price in USD:");
        
        // Get WBNB USD price
        try joeDexLens.getTokenPriceUSD(WBNB) returns (uint256 price) {
            console.log("   WBNB/USD Price:", price);
        } catch Error(string memory reason) {
            console.log("   WBNB/USD Price: Error -", reason);
        } catch {
            console.log("   WBNB/USD Price: Failed");
        }
        
        // Try to get other tokens' USD prices
        try joeDexLens.getTokenPriceUSD(USDC) returns (uint256 price) {
            console.log("   USDC/USD Price:", price);
        } catch Error(string memory reason) {
            console.log("   USDC/USD Price: Error -", reason);
        } catch {
            console.log("   USDC/USD Price: Failed");
        }
        
        try joeDexLens.getTokenPriceUSD(USDT) returns (uint256 price) {
            console.log("   USDT/USD Price:", price);
        } catch Error(string memory reason) {
            console.log("   USDT/USD Price: Error -", reason);
        } catch {
            console.log("   USDT/USD Price: Failed");
        }
        console.log("");
    }
    
    function callGetTokensPricesNative(IJoeDexLens joeDexLens) internal view {
        console.log("4. Batch Get Token Prices in Native:");
        
        address[] memory tokens = new address[](3);
        tokens[0] = WBNB;
        tokens[1] = USDC;
        tokens[2] = USDT;
        
        try joeDexLens.getTokensPricesNative(tokens) returns (uint256[] memory prices) {
            console.log("   Batch Native price query successful:");
            for (uint i = 0; i < tokens.length && i < prices.length; i++) {
                console.log("   Token", i, "Price:", prices[i]);
            }
        } catch {
            console.log("   Batch Native price query failed");
        }
        console.log("");
    }
    
    function callGetTokensPricesUSD(IJoeDexLens joeDexLens) internal view {
        console.log("5. Batch Get Token Prices in USD:");
        
        address[] memory tokens = new address[](3);
        tokens[0] = WBNB;
        tokens[1] = USDC;
        tokens[2] = USDT;
        
        try joeDexLens.getTokensPricesUSD(tokens) returns (uint256[] memory prices) {
            console.log("   Batch USD price query successful:");
            for (uint i = 0; i < tokens.length && i < prices.length; i++) {
                console.log("   Token", i, "USD Price:", prices[i]);
            }
        } catch {
            console.log("   Batch USD price query failed");
        }
        console.log("");
    }
}
