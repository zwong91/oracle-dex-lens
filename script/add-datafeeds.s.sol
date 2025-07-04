// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../src/interfaces/IJoeDexLens.sol";

contract AddDataFeeds is Script {
    // 已部署的代理合约地址
    address constant JOEDEXLENS_PROXY = 0x8C7dc8184F5D78Aa40430b2d37f78fDC3e9A9b78;

    // BSC测试网上的代币地址
    address constant WBNB = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd; // BSC测试网 WBNB
    address constant USDC = 0x64544969ed7EBf5f083679233325356EbE738930; // BSC测试网 USDC
    address constant USDT = 0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684; // BSC测试网 USDT

    // BSC测试网 Chainlink价格聚合器
    address constant USDC_USD_AGGREGATOR = 0x90c069C4538adAc136E051052E14c1cD799C41B7; // USDC/USD on BSC Testnet
    address constant USDT_USD_AGGREGATOR = 0xEca2605f0BCF2BA5966372C99837b1F182d3D620; // USDT/USD on BSC Testnet

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        console.log("=== Adding Data Feeds to JoeDexLens ===");
        console.log("Contract Address:", JOEDEXLENS_PROXY);
        console.log("");

        vm.startBroadcast(deployerPrivateKey);

        IJoeDexLens joeDexLens = IJoeDexLens(JOEDEXLENS_PROXY);

        // Remove existing data feeds (if any)
        _removeDataFeed(joeDexLens, USDC, USDC_USD_AGGREGATOR);
        _removeDataFeed(joeDexLens, USDT, USDT_USD_AGGREGATOR);

        // Add new USDC data feed with correct configuration
        _addDataFeed(joeDexLens, USDC, USDC_USD_AGGREGATOR);

        vm.stopBroadcast();

        console.log("");
        console.log("=== Data Feed Complete ===");
    }

    // Helper function to remove existing data feeds (tolerant to missing/invalid feeds)
    function _removeDataFeed(IJoeDexLens joeDexLens, address token, address aggregator) internal {
        console.log("Removing existing data feed for token:", token);
        try joeDexLens.removeDataFeed(token, aggregator) {
            console.log("[SUCCESS] Removed existing data feed for token:", token);
        } catch {
            console.log("[SKIP] Data feed for token does not exist or is already invalid:", token);
        }
    }

    // Helper function to add a new data feed
    function _addDataFeed(IJoeDexLens joeDexLens, address token, address aggregator) internal {
        IJoeDexLens.DataFeed memory newDataFeed = IJoeDexLens.DataFeed({
            collateralAddress: address(1), // USD representation
            dfAddress: aggregator,
            dfWeight: 1000, // 100% weight
            dfType: IJoeDexLens.DataFeedType.CHAINLINK
        });

        joeDexLens.addDataFeed(token, newDataFeed);
        console.log("[SUCCESS] Added new data feed for token:", token);
    }
}
