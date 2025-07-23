// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "openzeppelin/proxy/transparent/TransparentUpgradeableProxy.sol";
import "openzeppelin/proxy/transparent/ProxyAdmin.sol";

import "src/JoeDexLens.sol";

contract Deploy is Script {
    using stdJson for string;

    struct Deployment {
        address lbFactory2_2;
        address lbFactory2_1;
        address lbLegacyFactory;
        address joeFactory;
        address w_native;
        address native_usd_aggregator;
        address inverse_wbnb_aggregator;
        address multisig;
    }

<<<<<<< HEAD
    string[] chains = ["bnb_smart_chain_testnet", "bnb_smart_chain"];

    function setUp() public {
        _setupBSCTestnet();
        _setupBSC();
=======
    // Support both testnet and mainnet
    string[] chains;
    
    function setUp() public {
        // Check environment variable to determine which network to deploy to
        string memory targetNetwork = vm.envOr("TARGET_NETWORK", string("testnet"));
        
        if (keccak256(abi.encodePacked(targetNetwork)) == keccak256(abi.encodePacked("mainnet"))) {
            chains = ["bnb_smart_chain"];
            _setupBSC();
        } else {
            chains = ["bnb_smart_chain_testnet"];
            _setupBSCTestnet();
        }
>>>>>>> 262e00e (Add OracleDexLens documentation, scripts, and update contract references)
    }

    function run() public returns (JoeDexLens[] memory, ProxyAdmin[] memory, TransparentUpgradeableProxy[] memory) {
        string memory json = vm.readFile("script/config/deployments.json");
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        // Initialize arrays based on chains length
        JoeDexLens[] memory listJoeDexLens = new JoeDexLens[](chains.length);
        ProxyAdmin[] memory listProxyAdmin = new ProxyAdmin[](chains.length);
        TransparentUpgradeableProxy[] memory listTransparentUpgradeableProxy = new TransparentUpgradeableProxy[](chains.length);

        for (uint256 i = 0; i < chains.length; i++) {
            string memory networkKey = string(abi.encodePacked(".", chains[i]));
            
            // Create deployment struct with direct parsing
            Deployment memory deployment = Deployment({
                lbFactory2_2: vm.parseJsonAddress(json, string(abi.encodePacked(networkKey, ".lbFactory2_2"))),
                lbFactory2_1: vm.parseJsonAddress(json, string(abi.encodePacked(networkKey, ".lbFactory2_1"))),
                lbLegacyFactory: vm.parseJsonAddress(json, string(abi.encodePacked(networkKey, ".lbLegacyFactory"))),
                joeFactory: vm.parseJsonAddress(json, string(abi.encodePacked(networkKey, ".joeFactory"))),
                w_native: vm.parseJsonAddress(json, string(abi.encodePacked(networkKey, ".w_native"))),
                native_usd_aggregator: vm.parseJsonAddress(json, string(abi.encodePacked(networkKey, ".native_usd_aggregator"))),
                inverse_wbnb_aggregator: vm.parseJsonAddress(json, string(abi.encodePacked(networkKey, ".inverse_wbnb_aggregator"))),
                multisig: vm.parseJsonAddress(json, string(abi.encodePacked(networkKey, ".multisig")))
            });

            console.log("\n========================================");
            console.log("Deploying Dex Lens on %s", chains[i]);
            console.log("========================================");

            vm.createSelectFork(StdChains.getChain(chains[i]).rpcUrl);

            /**
             * Start broadcasting the transaction to the network.
             */
            vm.startBroadcast(deployerPrivateKey);

            console.log("1. Deploying ProxyAdmin...");
            ProxyAdmin proxyAdmin = new ProxyAdmin(msg.sender);
            console.log("   ProxyAdmin deployed at: %s", address(proxyAdmin));

            console.log("2. Deploying JoeDexLens implementation...");
            JoeDexLens implementation = new JoeDexLens(
                ILBFactory(deployment.lbFactory2_2),
                ILBFactory(deployment.lbFactory2_1),
                ILBLegacyFactory(address(0)),
                IJoeFactory(address(0)),
                deployment.w_native
            );
            console.log("   JoeDexLens implementation deployed at: %s", address(implementation));

            console.log("3. Setting up DataFeeds...");
            IJoeDexLens.DataFeed[] memory dataFeeds = new IJoeDexLens.DataFeed[](1);

            dataFeeds[0] = IJoeDexLens.DataFeed({
                collateralAddress: deployment.w_native,
                dfAddress: deployment.native_usd_aggregator,
                dfWeight: 1000,
                dfType: IJoeDexLens.DataFeedType.CHAINLINK
            });
            console.log("   DataFeed configured for WBNB/USD: %s", deployment.native_usd_aggregator);

            console.log("4. Deploying TransparentUpgradeableProxy...");
            TransparentUpgradeableProxy proxy = new TransparentUpgradeableProxy(
                address(implementation),
                address(proxyAdmin),
                abi.encodeWithSelector(JoeDexLens.initialize.selector, dataFeeds)
            );
            console.log("   *** MAIN CONTRACT (Proxy) deployed at: %s ***", address(proxy));

            listJoeDexLens[i] = implementation;
            listProxyAdmin[i] = proxyAdmin;
            listTransparentUpgradeableProxy[i] = proxy;

<<<<<<< HEAD
            console.log("5. Deployment completed successfully!");
            console.log("   Chain: %s (ID: %d)", chains[i], StdChains.getChain(chains[i]).chainId);
            console.log("   Implementation: %s", address(implementation));
            console.log("   ProxyAdmin: %s", address(proxyAdmin));
            console.log("   *** MAIN CONTRACT ADDRESS (USE THIS): %s ***", address(proxy));
            console.log("");
=======
            // Log deployment information
            console.log("\n=== Deployment Successful on %s ===", chains[i]);
            console.log("Implementation Contract:    %s", address(implementation));
            console.log("Proxy Admin:               %s", address(proxyAdmin));
            console.log("Proxy Contract (Main):     %s", address(proxy));
            console.log("WBNB/WNATIVE:             %s", deployment.w_native);
            console.log("Chainlink BNB/USD Feed:   %s", deployment.native_usd_aggregator);
            console.log("Multisig Owner:           %s", deployment.multisig);
            console.log("");
            console.log("Main contract to interact with: %s", address(proxy));
            console.log("=====================================\n");
>>>>>>> 262e00e (Add OracleDexLens documentation, scripts, and update contract references)

            // Note: Ownership transfer should be done manually after deployment
            // proxyAdmin.transferOwnership(deployment.multisig);
            // JoeDexLens(address(proxy)).setPendingOwner(deployment.multisig);

            vm.stopBroadcast();
            /**
             * Stop broadcasting the transaction to the network.
             */
<<<<<<< HEAD
            console.log("6. Verifying deployment...");
            implementation.getFactoryV2_2();
            implementation.getFactoryV2_1();
            console.log("   Verification complete!");
            console.log("========================================\n");
=======
            
            // Verify deployment by calling some view functions
            console.log("Verifying deployment...");
            console.log("Factory V2.2:             %s", address(implementation.getFactoryV2_2()));
            console.log("Factory V2.1:             %s", address(implementation.getFactoryV2_1()));
            console.log("WNative from contract:    %s", implementation.getWNative());
            
            // Test the proxy contract
            JoeDexLens proxyContract = JoeDexLens(address(proxy));
            console.log("Proxy WNative:            %s", proxyContract.getWNative());
            
            // Check if native token price can be fetched
            try proxyContract.getTokenPriceNative(deployment.w_native) returns (uint256 nativePrice) {
                console.log("Native token price:       %s", nativePrice);
            } catch {
                console.log("Native token price:       Failed to fetch (may be normal if no liquidity)");
            }
            
            try proxyContract.getTokenPriceUSD(deployment.w_native) returns (uint256 usdPrice) {
                console.log("USD price:                %s", usdPrice);
            } catch {
                console.log("USD price:                Failed to fetch (may be normal initially)");
            }
            
            console.log("Verification complete!\n");
>>>>>>> 262e00e (Add OracleDexLens documentation, scripts, and update contract references)
        }
        return (listJoeDexLens, listProxyAdmin, listTransparentUpgradeableProxy);
    }

    function _setupBSCTestnet() private {
        // Use environment variable for RPC URL if available, fallback to default
        string memory rpcUrl = vm.envOr("BNB_SMART_CHAIN_TESTNET_RPC_URL", string("https://data-seed-prebsc-1-s1.bnbchain.org:8545"));
        
        StdChains.setChain(
            "bnb_smart_chain_testnet",
            StdChains.ChainData({
                name: "BNB Smart Chain Testnet",
                chainId: 97,
                rpcUrl: rpcUrl
            })
        );
    }

    function _setupBSC() private {
        // Use environment variable for RPC URL if available, fallback to default
        string memory rpcUrl = vm.envOr("BSC_RPC_URL", string("https://bsc-dataseed.bnbchain.org"));

        StdChains.setChain(
            "bnb_smart_chain", StdChains.ChainData({name: "BNB Smart Chain", chainId: 56, rpcUrl: rpcUrl})
        );
    }
}
