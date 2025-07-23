// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../src/interfaces/IJoeDexLens.sol";

contract AddDataFeeds is Script {
    // 网络配置结构体
    struct NetworkConfig {
        address oracleDexLensProxy;
        address wbnb;
        address usdc;
        address usdt;
        address inverseWbnbAggregator;
        address bnbUsdAggregator;
        address usdcUsdAggregator;
        address usdtUsdAggregator;
        string networkName;
    }

    // 通用代币地址
    address constant INVERSE_WBNB_TOKEN = 0x0000000000000000000000000000000000000002;
    address constant USD_VIRTUAL = 0x0000000000000000000000000000000000000001;

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
                inverseWbnbAggregator: 0x440d1926FF183423EDC84a803f888915A1CDD8df,
                bnbUsdAggregator: 0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526,
                usdcUsdAggregator: 0x90c069C4538adAc136E051052E14c1cD799C41B7,
                usdtUsdAggregator: 0xEca2605f0BCF2BA5966372C99837b1F182d3D620,
                networkName: "BSC Testnet"
            });
        } else if (chainId == 56) {
            // BSC主网配置
            return NetworkConfig({
                oracleDexLensProxy: 0x8F4598bDfE142d2C8930a6A6c1B3F92e3975AeB1,
                wbnb: 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c,
                usdc: 0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d,
                usdt: 0x55d398326f99059fF775485246999027B3197955,
                inverseWbnbAggregator: 0xA89fe2F67d78F26F077E2811b2948399A4e5aF0A,
                bnbUsdAggregator: 0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE,
                usdcUsdAggregator: 0x51597f405303C4377E36123cBc172b13269EA163,
                usdtUsdAggregator: 0xB97Ad0E74fa7d920791E90258A6E2085088b4320,
                networkName: "BSC Mainnet"
            });
        } else {
            revert("Unsupported network");
        }
    }

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        NetworkConfig memory config = getNetworkConfig();

        console.log("=== Adding Data Feeds to OracleDexLens ===");
        console.log("Network:", config.networkName);
        console.log("Chain ID:", block.chainid);
        console.log("Contract Address:", config.oracleDexLensProxy);
        console.log("");

        // 检查反向聚合器地址是否已设置
        require(config.inverseWbnbAggregator != address(0), 
            string(abi.encodePacked("Please deploy InverseWBNBAggregator on ", config.networkName, " first and update the address")));

        vm.startBroadcast(deployerPrivateKey);

        IJoeDexLens joeDexLens = IJoeDexLens(config.oracleDexLensProxy);

        // 第一步：为 INVERSE_WBNB_TOKEN 设置数据源，使用反向聚合器
        _addInverseWBNBDataFeed(joeDexLens, config);

        // 第二步：为 USDC 和 USDT 设置数据源，使用 INVERSE_WBNB_TOKEN 作为 collateral
        _addUSDStablecoinWithInverseWBNB(joeDexLens, config.usdc, config.usdcUsdAggregator, config, "USDC");
        _addUSDStablecoinWithInverseWBNB(joeDexLens, config.usdt, config.usdtUsdAggregator, config, "USDT");

        vm.stopBroadcast();

        console.log("");
        console.log("=== Data Feed Setup Complete for", config.networkName, "===");
    }

    // Helper function to add "inverse WBNB" data feed
    function _addInverseWBNBDataFeed(IJoeDexLens joeDexLens, NetworkConfig memory config) internal {
        // 为反向 WBNB 代币添加数据源，使用我们部署的反向聚合器
        IJoeDexLens.DataFeed memory newDataFeed = IJoeDexLens.DataFeed({
            collateralAddress: config.wbnb, // 使用 WBNB 作为 collateral
            dfAddress: config.inverseWbnbAggregator, // 反向聚合器地址
            dfWeight: 1000, // 100% weight
            dfType: IJoeDexLens.DataFeedType.CHAINLINK
        });

        joeDexLens.addDataFeed(INVERSE_WBNB_TOKEN, newDataFeed);
        console.log("[SUCCESS] Added inverse WBNB data feed");
        console.log("  - Network:", config.networkName);
        console.log("  - Token (INVERSE_WBNB):", INVERSE_WBNB_TOKEN);
        console.log("  - Aggregator (InverseWBNBAggregator):", config.inverseWbnbAggregator);
        console.log("  - This represents 1/WBNB_USD price");
    }

    // Helper function to add USD stablecoin using inverse WBNB as collateral
    function _addUSDStablecoinWithInverseWBNB(
        IJoeDexLens joeDexLens, 
        address token, 
        address aggregator, 
        NetworkConfig memory config,
        string memory tokenName
    ) internal {
        IJoeDexLens.DataFeed memory newDataFeed = IJoeDexLens.DataFeed({
            collateralAddress: INVERSE_WBNB_TOKEN, // 使用反向 WBNB 代币作为 collateral
            dfAddress: aggregator,
            dfWeight: 1000, // 100% weight
            dfType: IJoeDexLens.DataFeedType.CHAINLINK
        });

        joeDexLens.addDataFeed(token, newDataFeed);
        console.log(string(abi.encodePacked("[SUCCESS] Added ", tokenName, " with inverse WBNB collateral")));
        console.log("  - Network:", config.networkName);
        console.log("  - Token:", token);
        console.log("  - Aggregator:", aggregator);
        console.log("  - Collateral (INVERSE_WBNB_TOKEN):", INVERSE_WBNB_TOKEN);
        console.log("  - Expected calculation: USD_price * (1/WBNB_USD) = price_in_WBNB");
    }
}
