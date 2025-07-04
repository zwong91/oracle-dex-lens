// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../src/interfaces/AggregatorV3Interface.sol";

contract TestChainlinkRaw is Script {
    // BSC测试网 Chainlink 聚合器地址
    address constant BNB_USD = 0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526; // BNB/USD
    address constant USDC_USD = 0x90c069C4538adAc136E051052E14c1cD799C41B7; // USDC/USD  
    address constant USDT_USD = 0xEca2605f0BCF2BA5966372C99837b1F182d3D620; // USDT/USD
    
    function run() external view {
        console.log("=== Testing Raw Chainlink Data ===");
        console.log("");
        
        testRawPrice("BNB/USD", BNB_USD);
        testRawPrice("USDC/USD", USDC_USD);
        testRawPrice("USDT/USD", USDT_USD);
    }
    
    function testRawPrice(string memory name, address aggregatorAddress) internal view {
        console.log("Testing", name, "Raw Price Data:");
        console.log("Aggregator:", aggregatorAddress);
        
        AggregatorV3Interface aggregator = AggregatorV3Interface(aggregatorAddress);
        
        try aggregator.latestRoundData() returns (
            uint80 roundId,
            int256 price,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        ) {
            console.log("  Round ID:", roundId);
            console.log("  Raw Price:", uint256(price));  // Convert to uint for display
            console.log("  Price (signed):");
            if (price >= 0) {
                console.log("    Positive:", uint256(price));
            } else {
                console.log("    NEGATIVE! This will cause revert");
                console.log("    Absolute value:", uint256(-price));
            }
            console.log("  Started At:", startedAt);
            console.log("  Updated At:", updatedAt);
            console.log("  Answered In Round:", answeredInRound);
            
            // Check if price is valid for JoeDexLens
            if (price <= 0) {
                console.log("  [ERROR] PRICE INVALID: price <= 0, JoeDexLens will revert!");
            } else {
                console.log("  [OK] Price valid for JoeDexLens");
            }
            
            // Check data freshness
            if (updatedAt == 0) {
                console.log("  [WARNING] No update timestamp");
            } else if (block.timestamp > updatedAt + 3600) {
                console.log("  [WARNING] Data is stale (>1 hour old)");
            } else {
                console.log("  [OK] Data is fresh");
            }
            
        } catch Error(string memory reason) {
            console.log("  [ERROR]:", reason);
        } catch {
            console.log("  [ERROR] Unknown error calling latestRoundData()");
        }
        
        console.log("");
    }
}
