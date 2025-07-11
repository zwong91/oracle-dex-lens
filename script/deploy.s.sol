// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "openzeppelin/proxy/transparent/TransparentUpgradeableProxy.sol";
import "openzeppelin/proxy/transparent/ProxyAdmin.sol";

import "src/JoeDexLens.sol";

contract Deploy is Script {
    using stdJson for string;

    struct Deployment {
        address lbFactory2_1;
        address lbFactory2_2;
        address joeFactory;
        address lbLegacyFactory;
        address multisig;
        address native_usd_aggregator;
        address w_native;
    }

    string[] chains = ["bnb_smart_chain_testnet", "bnb_smart_chain"];

    function setUp() public {
        _setupBSCTestnet();
        _setupBSC();
    }

    JoeDexLens[] listJoeDexLens = new JoeDexLens[](chains.length);
    ProxyAdmin[] listProxyAdmin = new ProxyAdmin[](chains.length);
    TransparentUpgradeableProxy[] listTransparentUpgradeableProxy = new TransparentUpgradeableProxy[](chains.length);

    function run() public returns (JoeDexLens[] memory, ProxyAdmin[] memory, TransparentUpgradeableProxy[] memory) {
        string memory json = vm.readFile("script/config/deployments.json");
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        for (uint256 i = 0; i < chains.length; i++) {
            bytes memory rawDeploymentData = json.parseRaw(string(abi.encodePacked(".", chains[i])));
            Deployment memory deployment = abi.decode(rawDeploymentData, (Deployment));

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
                ILBLegacyFactory(deployment.lbLegacyFactory),
                IJoeFactory(deployment.joeFactory),
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

            console.log("5. Deployment completed successfully!");
            console.log("   Chain: %s (ID: %d)", chains[i], StdChains.getChain(chains[i]).chainId);
            console.log("   Implementation: %s", address(implementation));
            console.log("   ProxyAdmin: %s", address(proxyAdmin));
            console.log("   *** MAIN CONTRACT ADDRESS (USE THIS): %s ***", address(proxy));
            console.log("");

            // Note: Ownership transfer should be done manually after deployment
            // proxyAdmin.transferOwnership(deployment.multisig);
            // JoeDexLens(address(proxy)).setPendingOwner(deployment.multisig);

            vm.stopBroadcast();
            /**
             * Stop broadcasting the transaction to the network.
             */
            console.log("6. Verifying deployment...");
            implementation.getFactoryV2_2();
            implementation.getFactoryV2_1();
            console.log("   Verification complete!");
            console.log("========================================\n");
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
