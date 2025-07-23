// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../src/interfaces/IJoeDexLens.sol";

contract AddDataFeeds is Script {
    // 已部署的代理合约地址
    address constant ORACLEDEXLENS_PROXY = 0xb512457fcB3020dC4a62480925B68dc83E776340;

    // BSC测试网上的代币地址
    address constant WBNB = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd; // BSC测试网 WBNB
    address constant USDC = 0x64544969ed7EBf5f083679233325356EbE738930; // BSC测试网 USDC
    address constant USDT = 0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684; // BSC测试网 USDT

    // 部署的反向聚合器地址 (需要先运行 deploy-inverse-aggregator.s.sol)
    // 替换为实际部署的地址
    address constant INVERSE_WBNB_AGGREGATOR = 0x440d1926FF183423EDC84a803f888915A1CDD8df; // 新部署的反向聚合器地址

    // 用于表示 "1/WBNB_USD" 的代币地址 (可以是任意地址，作为标识符)
    address constant INVERSE_WBNB_TOKEN = 0x0000000000000000000000000000000000000002;

    // 虚拟 USD 地址 - 用来表示 USD 价格基准
    address constant USD_VIRTUAL = 0x0000000000000000000000000000000000000001;

    // BSC测试网 Chainlink价格聚合器
    address constant BNB_USD_AGGREGATOR = 0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526;  // BNB/USD on BSC Testnet
    address constant USDC_USD_AGGREGATOR = 0x90c069C4538adAc136E051052E14c1cD799C41B7; // USDC/USD on BSC Testnet
    address constant USDT_USD_AGGREGATOR = 0xEca2605f0BCF2BA5966372C99837b1F182d3D620; // USDT/USD on BSC Testnet

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        console.log("=== Adding Data Feeds to OracleDexLens ===");
        console.log("Contract Address:", ORACLEDEXLENS_PROXY);
        console.log("");

        vm.startBroadcast(deployerPrivateKey);

        IJoeDexLens joeDexLens = IJoeDexLens(ORACLEDEXLENS_PROXY);

        // 检查反向聚合器地址是否已设置
        require(INVERSE_WBNB_AGGREGATOR != address(0), "Please deploy InverseWBNBAggregator first and update the address");

        // 第一步：为 INVERSE_WBNB_TOKEN 设置数据源，使用反向聚合器
        _addInverseWBNBDataFeed(joeDexLens, INVERSE_WBNB_TOKEN, INVERSE_WBNB_AGGREGATOR);

        // 第二步：为 USDC 和 USDT 设置数据源，使用 INVERSE_WBNB_TOKEN 作为 collateral
        _addUSDStablecoinWithInverseWBNB(joeDexLens, USDC, USDC_USD_AGGREGATOR);
        _addUSDStablecoinWithInverseWBNB(joeDexLens, USDT, USDT_USD_AGGREGATOR);

        vm.stopBroadcast();

        console.log("");
        console.log("=== Data Feed Complete ===");
    }

    // Helper function to add "inverse WBNB" data feed
    function _addInverseWBNBDataFeed(IJoeDexLens joeDexLens, address token, address aggregator) internal {
        // 为反向 WBNB 代币添加数据源，使用我们部署的反向聚合器
        IJoeDexLens.DataFeed memory newDataFeed = IJoeDexLens.DataFeed({
            collateralAddress: WBNB, // 使用 WBNB 作为 collateral
            dfAddress: aggregator, // 反向聚合器地址
            dfWeight: 1000, // 100% weight
            dfType: IJoeDexLens.DataFeedType.CHAINLINK
        });

        joeDexLens.addDataFeed(token, newDataFeed);
        console.log("[SUCCESS] Added inverse WBNB data feed");
        console.log("  - Token (INVERSE_WBNB):", token);
        console.log("  - Aggregator (InverseWBNBAggregator):", aggregator);
        console.log("  - This represents 1/WBNB_USD price");
    }

    // Helper function to add USD stablecoin using inverse WBNB as collateral
    function _addUSDStablecoinWithInverseWBNB(IJoeDexLens joeDexLens, address token, address aggregator) internal {
        IJoeDexLens.DataFeed memory newDataFeed = IJoeDexLens.DataFeed({
            collateralAddress: INVERSE_WBNB_TOKEN, // 使用反向 WBNB 代币作为 collateral
            dfAddress: aggregator,
            dfWeight: 1000, // 100% weight
            dfType: IJoeDexLens.DataFeedType.CHAINLINK
        });

        joeDexLens.addDataFeed(token, newDataFeed);
        console.log("[SUCCESS] Added USD stablecoin with inverse WBNB collateral");
        console.log("  - Token:", token);
        console.log("  - Aggregator:", aggregator);
        console.log("  - Collateral (INVERSE_WBNB_TOKEN):", INVERSE_WBNB_TOKEN);
        console.log("  - Expected calculation: USD_price * (1/WBNB_USD) = price_in_WBNB");
    }
}
