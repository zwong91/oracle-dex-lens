// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../src/interfaces/IJoeDexLens.sol";

contract AddDataFeeds is Script {
    // ✅ 主网上的已部署合约地址
    address constant JOEDEXLENS_PROXY = 0x817cF81C5FA4a5AF9F87010B7a9A20a60b485850;

    // ✅ BNB主网上的代币地址
    address constant WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address constant USDC = 0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d;
    address constant USDT = 0x55d398326f99059fF775485246999027B3197955;

    // ✅ BNB主网 Chainlink 聚合器地址（稳定币 -> USD）// Chainlink Aggregators (同一个地址用于 USDC 和 USDT)
    address constant CHAINLINK_USD_AGGREGATOR = 0x51597f405303C4377E36123cBc172b13269EA163;

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        console.log("=== Adding Data Feeds to JoeDexLens ===");
        console.log("Contract Address:", JOEDEXLENS_PROXY);
        console.log("");

        vm.startBroadcast(deployerPrivateKey);

        IJoeDexLens joeDexLens = IJoeDexLens(JOEDEXLENS_PROXY);

        // 如果需要删除旧的 data feed，取消注释
        // _removeDataFeed(joeDexLens, USDC, CHAINLINK_USD_AGGREGATOR);
        // _removeDataFeed(joeDexLens, USDT, CHAINLINK_USD_AGGREGATOR);

        // 添加新的 data feed
        _addDataFeed(joeDexLens, USDC, CHAINLINK_USD_AGGREGATOR);
        _addDataFeed(joeDexLens, USDT, CHAINLINK_USD_AGGREGATOR);

        vm.stopBroadcast();

        console.log("");
        console.log("=== Data Feed Complete ===");
    }

    function _removeDataFeed(IJoeDexLens joeDexLens, address token, address aggregator) internal {
        console.log("Removing existing data feed for token:", token);
        joeDexLens.removeDataFeed(token, aggregator);
        console.log("[SUCCESS] Removed existing data feed for token:", token);
    }

    function _addDataFeed(IJoeDexLens joeDexLens, address token, address aggregator) internal {
        IJoeDexLens.DataFeed memory newDataFeed = IJoeDexLens.DataFeed({
            collateralAddress: WBNB,
            dfAddress: aggregator,
            dfWeight: 1000, // 100%
            dfType: IJoeDexLens.DataFeedType.CHAINLINK
        });

        joeDexLens.addDataFeed(token, newDataFeed);
        console.log("[SUCCESS] Added new data feed for token:", token);
    }
}
