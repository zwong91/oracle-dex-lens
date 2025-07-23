// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";

contract DebugConfig is Script {
    using stdJson for string;

    struct Deployment {
        address lbFactory2_2;
        address lbFactory2_1;
        address w_native;
        address native_usd_aggregator;
        address inverse_wbnb_aggregator;
        address multisig;
    }

    function run() public {
        string memory json = vm.readFile("script/config/deployments.json");
        string memory networkKey = ".bnb_smart_chain";
        
        console.log("=== Direct JSON Field Parsing ===");
        // Parse individual fields to see exact values
        address lbFactory2_2 = vm.parseJsonAddress(json, string(abi.encodePacked(networkKey, ".lbFactory2_2")));
        address lbFactory2_1 = vm.parseJsonAddress(json, string(abi.encodePacked(networkKey, ".lbFactory2_1")));
        address w_native = vm.parseJsonAddress(json, string(abi.encodePacked(networkKey, ".w_native")));
        address native_usd_aggregator = vm.parseJsonAddress(json, string(abi.encodePacked(networkKey, ".native_usd_aggregator")));
        address multisig = vm.parseJsonAddress(json, string(abi.encodePacked(networkKey, ".multisig")));
        
        console.log("Direct lbFactory2_2:         %s", lbFactory2_2);
        console.log("Direct lbFactory2_1:         %s", lbFactory2_1);
        console.log("Direct w_native:             %s", w_native);
        console.log("Direct native_usd_aggregator: %s", native_usd_aggregator);
        console.log("Direct multisig:             %s", multisig);
        
        // Try to parse inverse_wbnb_aggregator if it exists
        try vm.parseJsonAddress(json, string(abi.encodePacked(networkKey, ".inverse_wbnb_aggregator"))) returns (address inverse_wbnb) {
            console.log("Direct inverse_wbnb_aggregator: %s", inverse_wbnb);
        } catch {
            console.log("inverse_wbnb_aggregator field not found in JSON");
        }
        
        console.log("\n=== Struct Decode Method ===");
        // Parse mainnet config using struct decode
        bytes memory rawDeploymentData = json.parseRaw(".bnb_smart_chain");
        Deployment memory deployment = abi.decode(rawDeploymentData, (Deployment));
        
        console.log("Struct lbFactory2_2:         %s", deployment.lbFactory2_2);
        console.log("Struct lbFactory2_1:         %s", deployment.lbFactory2_1);
        console.log("Struct w_native:             %s", deployment.w_native);
        console.log("Struct native_usd_aggregator: %s", deployment.native_usd_aggregator);
        console.log("Struct inverse_wbnb_aggregator: %s", deployment.inverse_wbnb_aggregator);
        console.log("Struct multisig:             %s", deployment.multisig);
        
        // Check for zero addresses
        console.log("\n=== Zero Address Check ===");
        console.log("lbFactory2_2 != 0:    %s", deployment.lbFactory2_2 != address(0));
        console.log("lbFactory2_1 != 0:    %s", deployment.lbFactory2_1 != address(0));
        console.log("w_native != 0:        %s", deployment.w_native != address(0));
        console.log("native_usd_aggregator != 0: %s", deployment.native_usd_aggregator != address(0));
        
        // Test the condition from JoeDexLens constructor
        bool allFactoriesZero = (deployment.lbFactory2_2 == address(0) && 
                                deployment.lbFactory2_1 == address(0));
        bool wNativeZero = deployment.w_native == address(0);
        
        console.log("\n=== Constructor Condition Test ===");
        console.log("All factories zero:   %s", allFactoriesZero);
        console.log("wNative is zero:      %s", wNativeZero);
        console.log("Should revert:        %s", allFactoriesZero || wNativeZero);
    }
}
