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
        (address _joeDexLensProxy, address _wbnb, address _usdc, address _usdt) = getAddresses();
        IJoeDexLens joeDexLens = IJoeDexLens(_joeDexLensProxy);
        
        console.log("=== JoeDexLens Test ===");
        console.log("Network:", getNetworkName());
        console.log("Contract:", _joeDexLensProxy);
        console.log("");
        
        testBasicInfo(joeDexLens);
        testPrices(joeDexLens, _wbnb, _usdc, _usdt);
        testDataFeeds(joeDexLens, _wbnb, _usdc, _usdt);
        
        console.log("=== Test Completed ===");
    }
    
    function getAddresses() internal view returns (address, address, address, address) {
        uint256 chainId = block.chainid;
        
        if (chainId == 97) {
            // BSC Testnet
            return (
                0xb512457fcB3020dC4a62480925B68dc83E776340,
                0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd,
                0x64544969ed7EBf5f083679233325356EbE738930,
                0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684
            );
        } else if (chainId == 56) {
            // BSC Mainnet
            return (
                0x8F4598bDfE142d2C8930a6A6c1B3F92e3975AeB1,
                0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c,
                0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d,
                0x55d398326f99059fF775485246999027B3197955
            );
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
    
    function testPrices(IJoeDexLens joeDexLens, address _wbnb, address _usdc, address _usdt) internal view {
        console.log("2. Price Queries:");
        
        // WBNB prices
        uint256 wbnbNative = joeDexLens.getTokenPriceNative(_wbnb);
        uint256 wbnbUSD = joeDexLens.getTokenPriceUSD(_wbnb);
        console.log("   WBNB Native:", wbnbNative);
        console.log("   WBNB USD:", wbnbUSD);
        
        // USDC prices
        uint256 usdcNative = joeDexLens.getTokenPriceNative(_usdc);
        uint256 usdcUSD = joeDexLens.getTokenPriceUSD(_usdc);
        console.log("   USDC Native:", usdcNative);
        console.log("   USDC USD:", usdcUSD);
        
        // USDT prices
        uint256 usdtNative = joeDexLens.getTokenPriceNative(_usdt);
        uint256 usdtUSD = joeDexLens.getTokenPriceUSD(_usdt);
        console.log("   USDT Native:", usdtNative);
        console.log("   USDT USD:", usdtUSD);
        console.log("");
    }
    
    function testDataFeeds(IJoeDexLens joeDexLens, address _wbnb, address _usdc, address _usdt) internal view {
        console.log("3. Data Feeds:");
        
        // WBNB data feeds
        IJoeDexLens.DataFeed[] memory wbnbFeeds = joeDexLens.getDataFeeds(_wbnb);
        console.log("   WBNB feeds:", wbnbFeeds.length);
        
        // USDC data feeds
        IJoeDexLens.DataFeed[] memory usdcFeeds = joeDexLens.getDataFeeds(_usdc);
        console.log("   USDC feeds:", usdcFeeds.length);
        
        // USDT data feeds
        IJoeDexLens.DataFeed[] memory usdtFeeds = joeDexLens.getDataFeeds(_usdt);
        console.log("   USDT feeds:", usdtFeeds.length);
        
        console.log("");
    }
}
