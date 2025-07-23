// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "./InverseWBNBAggregator.sol";

contract DeployInverseAggregator is Script {
    // BSC测试网 BNB/USD Chainlink聚合器
    address constant BNB_USD_AGGREGATOR = 0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526;

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        console.log("=== Deploying Inverse WBNB Aggregator ===");
        console.log("BNB/USD Aggregator:", BNB_USD_AGGREGATOR);
        console.log("");

        vm.startBroadcast(deployerPrivateKey);

        // 部署反向 WBNB 聚合器
        InverseWBNBAggregator inverseAggregator = new InverseWBNBAggregator(BNB_USD_AGGREGATOR);

        vm.stopBroadcast();

        console.log("[SUCCESS] Deployed InverseWBNBAggregator");
        console.log("  - Contract Address:", address(inverseAggregator));
        console.log("  - Description:", inverseAggregator.description());
        console.log("  - Decimals:", inverseAggregator.decimals());
        
        // 测试聚合器
        try inverseAggregator.latestRoundData() returns (
            uint80 roundId,
            int256 answer,
            uint256, // startedAt
            uint256, // updatedAt
            uint80   // answeredInRound
        ) {
            console.log("  - Test Price (1/BNB_USD):", uint256(answer));
            console.log("  - Round ID:", roundId);
        } catch {
            console.log("  - Failed to get test price");
        }
        
        console.log("");
        console.log("=== Deployment Complete ===");
        console.log("Use this address as INVERSE_WBNB in your data feed script:");
        console.log(address(inverseAggregator));
    }
}
