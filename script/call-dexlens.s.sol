// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../src/interfaces/IJoeDexLens.sol";

contract CallJoeDexLens is Script {
    address joeDexLensProxy;
    address wbnb;
    address usdc;
    address usdt;
    
    function run() external view {
        setupAddresses();
        IJoeDexLens joeDexLens = IJoeDexLens(joeDexLensProxy);
        
        console.log("=== JoeDexLens Test ===");
        console.log("Network:", getNetworkName());
        console.log("Contract:", joeDexLensProxy);
        console.log("");
        
        testBasicInfo(joeDexLens);
        testPrices(joeDexLens);
        testDataFeeds(joeDexLens);
        
        console.log("=== Test Completed ===");
    }
    
    function setupAddresses() internal {
        uint256 chainId = block.chainid;
        
        if (chainId == 97) {
            // BSC Testnet
            joeDexLensProxy = 0xb512457fcB3020dC4a62480925B68dc83E776340;
            wbnb = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;
            usdc = 0x64544969ed7EBf5f083679233325356EbE738930;
            usdt = 0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684;
        } else if (chainId == 56) {
            // BSC Mainnet
            joeDexLensProxy = 0x8F4598bDfE142d2C8930a6A6c1B3F92e3975AeB1;
            wbnb = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
            usdc = 0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d;
            usdt = 0x55d398326f99059fF775485246999027B3197955;
        } else {
            revert("Unsupported network");
        }
    }
    
    function getNetworkName() internal view returns (string memory) {
        uint256 chainId = block.chainid;
        if (chainId == 97) return "BSC Testnet";
        if (chainId == 56) return "BSC Mainnet";
        return "Unknown";
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
        uint256 wbnbNative = joeDexLens.getTokenPriceNative(wbnb);
        uint256 wbnbUSD = joeDexLens.getTokenPriceUSD(wbnb);
        console.log("   WBNB Native:", wbnbNative);
        console.log("   WBNB USD:", wbnbUSD);
        
        // USDC prices
        uint256 usdcNative = joeDexLens.getTokenPriceNative(usdc);
        uint256 usdcUSD = joeDexLens.getTokenPriceUSD(usdc);
        console.log("   USDC Native:", usdcNative);
        console.log("   USDC USD:", usdcUSD);
        
        // USDT prices
        uint256 usdtNative = joeDexLens.getTokenPriceNative(usdt);
        uint256 usdtUSD = joeDexLens.getTokenPriceUSD(usdt);
        console.log("   USDT Native:", usdtNative);
        console.log("   USDT USD:", usdtUSD);
        console.log("");
    }
    
    function testDataFeeds(IJoeDexLens joeDexLens) internal view {
        console.log("3. Data Feeds:");
        
        // WBNB data feeds
        IJoeDexLens.DataFeed[] memory wbnbFeeds = joeDexLens.getDataFeeds(wbnb);
        console.log("   WBNB feeds:", wbnbFeeds.length);
        
        // USDC data feeds
        IJoeDexLens.DataFeed[] memory usdcFeeds = joeDexLens.getDataFeeds(usdc);
        console.log("   USDC feeds:", usdcFeeds.length);
        
        // USDT data feeds
        IJoeDexLens.DataFeed[] memory usdtFeeds = joeDexLens.getDataFeeds(usdt);
        console.log("   USDT feeds:", usdtFeeds.length);
        
        console.log("");
    }
}
