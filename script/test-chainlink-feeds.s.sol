// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../src/interfaces/AggregatorV3Interface.sol";

contract TestChainlinkFeeds is Script {
    // BSC testnet Chainlink aggregators
    address constant BNB_USD_AGGREGATOR = 0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526;
    address constant USDC_USD_AGGREGATOR = 0x90c069C4538adAc136E051052E14c1cD799C41B7;
    address constant USDT_USD_AGGREGATOR = 0xEca2605f0BCF2BA5966372C99837b1F182d3D620;

    function run() external view {
        console.log("=== Testing Chainlink Price Feeds ===");
        console.log("");

        _testAggregator("BNB/USD", BNB_USD_AGGREGATOR);
        _testAggregator("USDC/USD", USDC_USD_AGGREGATOR);  
        _testAggregator("USDT/USD", USDT_USD_AGGREGATOR);
    }

    function _testAggregator(string memory name, address aggregatorAddress) internal view {
        console.log("Testing", name, "at", aggregatorAddress);
        
        if (aggregatorAddress.code.length == 0) {
            console.log("  [ERROR] No contract code at address");
            console.log("");
            return;
        }
        
        AggregatorV3Interface aggregator = AggregatorV3Interface(aggregatorAddress);
        
        try aggregator.decimals() returns (uint8 decimals) {
            console.log("  - Decimals:", decimals);
        } catch {
            console.log("  [ERROR] Failed to get decimals");
            console.log("");
            return;
        }
        
        try aggregator.latestRoundData() returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        ) {
            console.log("  [SUCCESS] Latest price:", uint256(answer));
            console.log("  - Round ID:", roundId);
            console.log("  - Updated at:", updatedAt);
            console.log("  - Started at:", startedAt);
            console.log("  - Answered in round:", answeredInRound);
        } catch Error(string memory reason) {
            console.log("  [ERROR] latestRoundData failed:", reason);
        } catch {
            console.log("  [ERROR] latestRoundData failed with unknown reason");
        }
        
        console.log("");
    }
}
