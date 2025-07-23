// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../src/interfaces/IJoeDexLens.sol";

contract VerifyDataFeeds is Script {
    // 网络配置结构体
    struct NetworkConfig {
        address oracleDexLensProxy;
        address wbnb;
        address usdc;
        address usdt;
        address inverseWbnbToken;
        string networkName;
    }

    // 通用代币地址
    address constant INVERSE_WBNB_TOKEN = 0x0000000000000000000000000000000000000002;

    // 获取网络配置
    function getNetworkConfig() internal view returns (NetworkConfig memory) {
        uint256 chainId = block.chainid;
        
        if (chainId == 97) {
            // BSC测试网配置
            return NetworkConfig({
                oracleDexLensProxy: 0xb512457fcB3020dC4a62480925B68dc83E776340,
                wbnb: 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd,
                usdc: 0x64544969ed7EBf5f083679233325356EbE738930,
                usdt: 0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684,
                inverseWbnbToken: INVERSE_WBNB_TOKEN,
                networkName: "BSC Testnet"
            });
        } else if (chainId == 56) {
            // BSC主网配置
            return NetworkConfig({
                oracleDexLensProxy: 0x817cF81C5FA4a5AF9F87010B7a9A20a60b485850,
                wbnb: 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c,
                usdc: 0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d,
                usdt: 0x55d398326f99059fF775485246999027B3197955,
                inverseWbnbToken: INVERSE_WBNB_TOKEN,
                networkName: "BSC Mainnet"
            });
        } else {
            revert("Unsupported network");
        }
    }

    function run() external view {
        NetworkConfig memory config = getNetworkConfig();
        
        console.log("=== Verifying Data Feeds ===");
        console.log("Network:", config.networkName);
        console.log("Chain ID:", block.chainid);
        console.log("Contract Address:", config.oracleDexLensProxy);
        console.log("");

        IJoeDexLens joeDexLens = IJoeDexLens(config.oracleDexLensProxy);

        // Test Inverse WBNB price
        _testTokenPrice(joeDexLens, "Inverse WBNB", config.inverseWbnbToken, config.wbnb, config.networkName);
        
        // Test USDC price in WBNB
        _testTokenPrice(joeDexLens, "USDC", config.usdc, config.wbnb, config.networkName);
        
        // Test USDT price in WBNB
        _testTokenPrice(joeDexLens, "USDT", config.usdt, config.wbnb, config.networkName);

        console.log("");
        console.log("=== Verification Complete ===");
    }

    function _testTokenPrice(IJoeDexLens joeDexLens, string memory tokenName, address token, address collateral, string memory networkName) internal view {
        console.log("Testing token:", tokenName);
        console.log("  - Network:", networkName);
        console.log("  - Token:", token);
        console.log("  - Collateral:", collateral);
        
        // First check if data feeds exist
        try joeDexLens.getDataFeeds(token) returns (IJoeDexLens.DataFeed[] memory dataFeeds) {
            console.log("  - Data feeds count:", dataFeeds.length);
            if (dataFeeds.length > 0) {
                console.log("  - First data feed address:", dataFeeds[0].dfAddress);
                console.log("  - First data feed weight:", dataFeeds[0].dfWeight);
                console.log("  - First data feed type:", uint256(dataFeeds[0].dfType));
                console.log("  - First data feed collateral:", dataFeeds[0].collateralAddress);
            }
        } catch {
            console.log("  [ERROR] Failed to get data feeds");
        }
        
        // Test getting price in native token (WBNB)
        if (collateral == token) { // Skip self-comparison for inverse WBNB
            console.log("  - Skipping native price test for inverse token");
        } else {
            try joeDexLens.getTokenPriceNative(token) returns (uint256 price) {
                console.log("  - Native price:", price);
                console.log("  [SUCCESS] Native price retrieved");
            } catch Error(string memory reason) {
                console.log("  [ERROR] Native price failed:", reason);
            } catch {
                console.log("  [ERROR] Native price failed");
            }
        }
        
        // Test getting price in USD
        try joeDexLens.getTokenPriceUSD(token) returns (uint256 price) {
            console.log("  - USD price:", price);
            console.log("  [SUCCESS] USD price retrieved");
        } catch Error(string memory reason) {
            console.log("  [ERROR] USD price failed:", reason);
        } catch {
            console.log("  [ERROR] USD price failed");
        }
        
        console.log("");
    }
}
