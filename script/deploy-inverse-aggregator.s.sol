// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "./InverseWBNBAggregator.sol";

contract DeployInverseAggregator is Script {
    // 网络配置结构体
    struct NetworkConfig {
        address bnbUsdAggregator;
        string networkName;
    }

    // 获取网络配置
    function getNetworkConfig() internal view returns (NetworkConfig memory) {
        uint256 chainId = block.chainid;
        
        if (chainId == 97) {
            // BSC测试网配置
            return NetworkConfig({
                bnbUsdAggregator: 0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526,
                networkName: "BSC Testnet"
            });
        } else if (chainId == 56) {
            // BSC主网配置
            return NetworkConfig({
                bnbUsdAggregator: 0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE,
                networkName: "BSC Mainnet"
            });
        } else {
            revert("Unsupported network");
        }
    }

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        NetworkConfig memory config = getNetworkConfig();

        console.log("=== Deploying Inverse WBNB Aggregator ===");
        console.log("Network:", config.networkName);
        console.log("Chain ID:", block.chainid);
        console.log("BNB/USD Aggregator:", config.bnbUsdAggregator);
        console.log("");

        vm.startBroadcast(deployerPrivateKey);

        // 部署反向 WBNB 聚合器
        InverseWBNBAggregator inverseAggregator = new InverseWBNBAggregator(config.bnbUsdAggregator);

        vm.stopBroadcast();

        console.log("[SUCCESS] Deployed InverseWBNBAggregator");
        console.log("  - Network:", config.networkName);
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
        console.log("Copy this address to add-datafeeds.s.sol for", config.networkName);
        console.log("INVERSE_WBNB_AGGREGATOR =", address(inverseAggregator));
    }
}
