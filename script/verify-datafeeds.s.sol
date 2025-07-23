// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../src/interfaces/IJoeDexLens.sol";

contract VerifyDataFeeds is Script {
    address constant ORACLEDEXLENS_PROXY = 0xb512457fcB3020dC4a62480925B68dc83E776340;
    
    // Tokens
    address constant USDC = 0x64544969ed7EBf5f083679233325356EbE738930;
    address constant USDT = 0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684;
    address constant INVERSE_WBNB_TOKEN = 0x0000000000000000000000000000000000000002;
    address constant WBNB = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;

    function run() external view {
        console.log("=== Verifying Data Feeds ===");
        console.log("");

        IJoeDexLens joeDexLens = IJoeDexLens(ORACLEDEXLENS_PROXY);

        // Test Inverse WBNB price
        _testTokenPrice(joeDexLens, "Inverse WBNB", INVERSE_WBNB_TOKEN, WBNB);
        
        // Test USDC price in WBNB
        _testTokenPrice(joeDexLens, "USDC", USDC, WBNB);
        
        // Test USDT price in WBNB
        _testTokenPrice(joeDexLens, "USDT", USDT, WBNB);

        console.log("");
        console.log("=== Verification Complete ===");
    }

    function _testTokenPrice(IJoeDexLens joeDexLens, string memory tokenName, address token, address collateral) internal view {
        console.log("Testing", tokenName, "price...");
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
        if (collateral == WBNB) {
            try joeDexLens.getTokenPriceNative(token) returns (uint256 price) {
                console.log("  - Native price:", price);
                console.log("  [SUCCESS]", tokenName, "native price retrieved");
            } catch Error(string memory reason) {
                console.log("  [ERROR]", tokenName, "native price failed:", reason);
            } catch {
                console.log("  [ERROR]", tokenName, "native price failed with unknown reason");
            }
        }
        
        // Test getting price in USD
        try joeDexLens.getTokenPriceUSD(token) returns (uint256 price) {
            console.log("  - USD price:", price);
            console.log("  [SUCCESS]", tokenName, "USD price retrieved");
        } catch Error(string memory reason) {
            console.log("  [ERROR]", tokenName, "USD price failed:", reason);
        } catch {
            console.log("  [ERROR]", tokenName, "USD price failed with unknown reason");
        }
        
        console.log("");
    }
}
