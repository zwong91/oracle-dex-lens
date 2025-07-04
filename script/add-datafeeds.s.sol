// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../src/interfaces/IJoeDexLens.sol";

contract AddDataFeedsFixed is Script {
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
        
        console.log("=== Adding FIXED Data Feeds to JoeDexLens ===");
        console.log("Contract Address:", JOEDEXLENS_PROXY);
        console.log("");
        
        vm.startBroadcast(deployerPrivateKey);
        
        IJoeDexLens joeDexLens = IJoeDexLens(JOEDEXLENS_PROXY);
        
        // 首先移除错误的数据源（如果存在）
        console.log("Removing existing USDC data feed...");
        try joeDexLens.removeDataFeed(USDC, USDC_USD_AGGREGATOR) {
            console.log("[SUCCESS] Removed existing USDC data feed");
        } catch {
            console.log("[INFO] No existing USDC data feed to remove");
        }
        
        console.log("Removing existing USDT data feed...");
        try joeDexLens.removeDataFeed(USDT, USDT_USD_AGGREGATOR) {
            console.log("[SUCCESS] Removed existing USDT data feed");
        } catch {
            console.log("[INFO] No existing USDT data feed to remove");
        }
        
        // 正确的配置：对于USD稳定币，我们需要一个代表USD的地址
        // 使用 address(1) 作为 USD 的代表地址，让合约执行价格转换
        // 转换逻辑：USDC_USD_price * USD_native_price / precision = USDC/Native price
        
        // Add USDC/USD Chainlink data feed - 修复配置
        IJoeDexLens.DataFeed memory usdcDataFeed = IJoeDexLens.DataFeed({
            collateralAddress: address(1), // 使用address(1)作为USD代表地址，触发价格转换
            dfAddress: USDC_USD_AGGREGATOR,
            dfWeight: 1000, // 100% weight
            dfType: IJoeDexLens.DataFeedType.CHAINLINK
        });
        
        try joeDexLens.addDataFeed(USDC, usdcDataFeed) {
            console.log("[SUCCESS] USDC Chainlink data feed added with corrected configuration");
        } catch Error(string memory reason) {
            console.log("[FAILED] Failed to add USDC data feed:", reason);
        } catch {
            console.log("[FAILED] Failed to add USDC data feed - unknown error");
        }
        
        vm.stopBroadcast();
        
        console.log("");
        console.log("=== Data Feed Fix Complete ===");
    }
}
