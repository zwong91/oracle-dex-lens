// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../src/interfaces/AggregatorV3Interface.sol";

contract TestChainlink is Script {
    // BSC测试网 Chainlink 聚合器地址
    address constant BNB_USD = 0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526; // BNB/USD
    address constant USDC_USD = 0x90c069C4538adAc136E051052E14c1cD799C41B7; // USDC/USD  
    address constant USDT_USD = 0xEca2605f0BCF2BA5966372C99837b1F182d3D620; // USDT/USD
    
    function run() external view {
        console.log("=== Testing Chainlink Aggregators on BSC Testnet ===");
        console.log("");
        
        testAggregator("BNB/USD", BNB_USD);
        testAggregator("USDC/USD", USDC_USD);
        testAggregator("USDT/USD", USDT_USD);
    }
    
    function testAggregator(string memory name, address aggregatorAddress) internal view {
        console.log("Testing", name, "Aggregator:", aggregatorAddress);
        
        // 检查聚合器是否存在
        uint256 codeSize;
        assembly {
            codeSize := extcodesize(aggregatorAddress)
        }
        
        if (codeSize == 0) {
            console.log("  ERROR: No contract at this address!");
            console.log("");
            return;
        }
        
        console.log("  Contract exists, code size:", codeSize);
        
        try AggregatorV3Interface(aggregatorAddress).decimals() returns (uint8 decimals) {
            console.log("  Decimals:", decimals);
        } catch {
            console.log("  ERROR: Failed to get decimals");
        }
        
        try AggregatorV3Interface(aggregatorAddress).description() returns (string memory description) {
            console.log("  Description:", description);
        } catch {
            console.log("  ERROR: Failed to get description");
        }
        
        try AggregatorV3Interface(aggregatorAddress).latestRoundData() returns (
            uint80 roundId,
            int256 price,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        ) {
            console.log("  Latest Price:", uint256(price));
            console.log("  Round ID:", roundId);
            console.log("  Updated At:", updatedAt);
            console.log("  Block timestamp:", block.timestamp);
            
            if (updatedAt == 0) {
                console.log("  WARNING: No price data available!");
            } else if (block.timestamp - updatedAt > 3600) {
                console.log("  WARNING: Price data is stale (>1 hour old)");
            } else {
                console.log("  Price data is fresh");
            }
        } catch Error(string memory reason) {
            console.log("  ERROR getting latest price:", reason);
        } catch {
            console.log("  ERROR: Failed to get latest price data");
        }
        
        console.log("");
    }
}
