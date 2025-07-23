// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../src/interfaces/AggregatorV3Interface.sol";
import "./InverseWBNBAggregator.sol";

contract DebugAggregator is Script {
    // BSC测试网聚合器地址
    address constant BNB_USD_AGGREGATOR = 0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526;
    address constant INVERSE_WBNB_AGGREGATOR = 0x3F12A2098E121B1251f685C28dfB14dcdb2dC07D;

    function run() external view {
        console.log("=== Debugging Aggregators ===");
        console.log("");

        // 测试 BNB/USD 聚合器
        console.log("1. Testing BNB/USD Aggregator:", BNB_USD_AGGREGATOR);
        AggregatorV3Interface bnbUsdAggregator = AggregatorV3Interface(BNB_USD_AGGREGATOR);
        
        try bnbUsdAggregator.latestRoundData() returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        ) {
            console.log("  [SUCCESS] BNB/USD Price:", uint256(answer));
            console.log("  - Decimals:", bnbUsdAggregator.decimals());
            console.log("  - Round ID:", roundId);
            console.log("  - Updated At:", updatedAt);
        } catch Error(string memory reason) {
            console.log("  [ERROR] BNB/USD failed:", reason);
        } catch {
            console.log("  [ERROR] BNB/USD failed with unknown reason");
        }

        console.log("");
        
        // 测试反向聚合器
        console.log("2. Testing Inverse WBNB Aggregator:", INVERSE_WBNB_AGGREGATOR);
        InverseWBNBAggregator inverseAggregator = InverseWBNBAggregator(INVERSE_WBNB_AGGREGATOR);
        
        try inverseAggregator.latestRoundData() returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        ) {
            console.log("  [SUCCESS] Inverse Price:", uint256(answer));
            console.log("  - Decimals:", inverseAggregator.decimals());
            console.log("  - Round ID:", roundId);
        } catch Error(string memory reason) {
            console.log("  [ERROR] Inverse aggregator failed:", reason);
        } catch {
            console.log("  [ERROR] Inverse aggregator failed with unknown reason");
        }

        console.log("");
        console.log("=== Debug Complete ===");
    }
}
