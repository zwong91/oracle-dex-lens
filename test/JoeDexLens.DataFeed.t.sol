// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "lb-dlmm/interfaces/ILBRouter.sol";
import "openzeppelin/proxy/transparent/TransparentUpgradeableProxy.sol";
import "openzeppelin/access/Ownable.sol";

import "../src/JoeDexLens.sol";
import "./TestHelper.sol";

contract TestJoeDexLens is TestHelper {
    uint256 BNB_PRICE = 661.1e18;

    ILBLegacyFactory private _legacyFactory = ILBLegacyFactory(address(0));
    IJoeFactory private _factoryV1 = IJoeFactory(address(0));

    function setUp() public override {
        vm.createSelectFork(vm.rpcUrl("bsc_testnet")); // 使用最新区块
        super.setUp();

        JoeDexLens imp = new JoeDexLens(lbFactory, lbFactory, _legacyFactory, _factoryV1, wNative);

        joeDexLens = JoeDexLens(address(new TransparentUpgradeableProxy(address(imp), address(1), "")));

        IJoeDexLens.DataFeed[] memory dataFeeds = new IJoeDexLens.DataFeed[](2);
        dataFeeds[0] = IJoeDexLens.DataFeed(USDC, BNB_USDC_25BP, 1000, IJoeDexLens.DataFeedType.V2_2);
        dataFeeds[1] = IJoeDexLens.DataFeed(USDT, BNB_USDT_10BP, 100, IJoeDexLens.DataFeedType.V2_2);

        joeDexLens.initialize(dataFeeds);
    }

    function test_GetNativePrice() public {
        assertApproxEqRel(joeDexLens.getTokenPriceUSD(wNative), BNB_PRICE, 1e16, "test_GetNativePrice::1");
        assertEq(joeDexLens.getTokenPriceNative(wNative), 1e18, "test_GetNativePrice::2");
    }

    function test_GetTokenPriceUsingNativeDataFeeds() public {
        joeDexLens.addDataFeed(USDC, IJoeDexLens.DataFeed(wNative, BNB_USDC_25BP, 1000, IJoeDexLens.DataFeedType.V2_2));
        assertApproxEqAbs(joeDexLens.getTokenPriceUSD(USDC), 1e18, 0.05e18, "test_GetTokenPriceUsingNativeDataFeeds::1");
        assertApproxEqAbs(
            joeDexLens.getTokenPriceNative(USDC),
            uint256(1e36) / BNB_PRICE,
            0.05e18,
            "test_GetTokenPriceUsingNativeDataFeeds::2"
        );

        joeDexLens.removeDataFeed(USDC, BNB_USDC_25BP);
        joeDexLens.addDataFeed(USDC, IJoeDexLens.DataFeed(wNative, BNB_USDC_25BP, 1000, IJoeDexLens.DataFeedType.V2_2));
        assertApproxEqAbs(joeDexLens.getTokenPriceUSD(USDC), 1e18, 0.05e18, "test_GetTokenPriceUsingNativeDataFeeds::3");
        assertApproxEqAbs(
            joeDexLens.getTokenPriceNative(USDC),
            uint256(1e36) / BNB_PRICE,
            0.05e18,
            "test_GetTokenPriceUsingNativeDataFeeds::4"
        );
    }

    function test_GetTokenPriceUsingDataFeeds() public {
        // Use correct pairs: USDC should use BNB_USDC_25BP, USDT should use BNB_USDT_10BP
        joeDexLens.addDataFeed(USDT, IJoeDexLens.DataFeed(wNative, BNB_USDT_10BP, 1000, IJoeDexLens.DataFeedType.V2_2));
        joeDexLens.addDataFeed(wNative, IJoeDexLens.DataFeed(USDC, BNB_USDC_25BP, 1000, IJoeDexLens.DataFeedType.V2_2));
        assertApproxEqAbs(joeDexLens.getTokenPriceUSD(USDC), 1e18, 0.05e18, "test_GetTokenPriceUsingDataFeeds::1");
        assertApproxEqAbs(
            joeDexLens.getTokenPriceNative(USDC),
            uint256(1e36) / BNB_PRICE,
            0.05e18,
            "test_GetTokenPriceUsingDataFeeds::2"
        );
        joeDexLens.addDataFeed(USDC, IJoeDexLens.DataFeed(wNative, BNB_USDC_25BP, 1000, IJoeDexLens.DataFeedType.V2_2));
        joeDexLens.addDataFeed(wNative, IJoeDexLens.DataFeed(USDC, BNB_USDC_25BP, 1000, IJoeDexLens.DataFeedType.V2_2));
        assertApproxEqAbs(joeDexLens.getTokenPriceUSD(USDC), 1e18, 0.05e18, "test_GetTokenPriceUsingDataFeeds::3");
        assertApproxEqAbs(
            joeDexLens.getTokenPriceNative(USDC),
            uint256(1e36) / BNB_PRICE,
            0.05e18,
            "test_GetTokenPriceUsingDataFeeds::4"
        );
    }

    function test_GetTokenPriceUsingNativeFallback() public {
        joeDexLens.addDataFeed(USDT, IJoeDexLens.DataFeed(wNative, BNB_USDT_10BP, 1000, IJoeDexLens.DataFeedType.V2_2));
        joeDexLens.addDataFeed(USDC, IJoeDexLens.DataFeed(wNative, BNB_USDC_25BP, 1000, IJoeDexLens.DataFeedType.V2_2));
        assertApproxEqAbs(joeDexLens.getTokenPriceUSD(USDC), 1e18, 0.05e18, "test_GetTokenPriceUsingNativeFallback::1");
    }

    function testGetTokenPriceUsingFallback() public {
        uint24 ID_10_25bp = 8389530;
        uint24 ID_0_25_25bp = 8388052;

        address newToken0 = address(new ERC20MockDecimals(6));

        // Unlock the preset for users before creating pairs
        vm.prank(Ownable(address(lbFactory)).owner());
        lbFactory.setPresetOpenState(DEFAULT_BIN_STEP, true);

        address pair0 = createLBPairV2_2(newToken0, USDC, ID_10_25bp);

        vm.label(newToken0, "newToken0");
        vm.label(pair0, "token0_usdc_25bp");

        addLiquidityV2_2(pair0, 1000e6, 100e6);

        assertEq(joeDexLens.getTokenPriceUSD(address(newToken0)), 0, "test_GetTokenPriceUsingFallback::1");

        joeDexLens.addDataFeed(USDC, IJoeDexLens.DataFeed(wNative, BNB_USDC_25BP, 1000, IJoeDexLens.DataFeedType.V2_2));

        address[] memory trustedTokens = new address[](1);
        trustedTokens[0] = USDC;

        joeDexLens.setTrustedTokensAt(1, trustedTokens);

        assertApproxEqRel(
            joeDexLens.getTokenPriceNative(address(newToken0)),
            uint256(1e36) / BNB_PRICE * 10,
            0.01e18,
            "test_GetTokenPriceUsingFallback::2"
        );
        assertApproxEqRel(
            joeDexLens.getTokenPriceUSD(address(newToken0)), 10e18, 1e16, "test_GetTokenPriceUsingFallback::3"
        );

        address newToken1 = address(new ERC20MockDecimals(6));

        vm.label(newToken1, "newToken1");

        vm.prank(Ownable(address(lbFactory)).owner());
        lbFactory.addQuoteAsset(IERC20(newToken0));

        address pair1 = createLBPairV2_2(newToken1, newToken0, ID_0_25_25bp);
        addLiquidityV2_2(pair1, 1000e8, 100e6);

        assertEq(joeDexLens.getTokenPriceUSD(address(newToken1)), 0, "test_GetTokenPriceUsingFallback::4");

        joeDexLens.addDataFeed(
            address(newToken0), IJoeDexLens.DataFeed(USDC, pair0, 1000, IJoeDexLens.DataFeedType.V2_2)
        );

        trustedTokens = new address[](2);

        trustedTokens[0] = USDC;
        trustedTokens[1] = newToken0;

        joeDexLens.setTrustedTokensAt(1, trustedTokens);

        assertApproxEqRel(
            joeDexLens.getTokenPriceNative(address(newToken1)),
            uint256(1e36) * 25 / 10 / BNB_PRICE,
            0.01e18,
            "test_GetTokenPriceUsingFallback::5"
        );
        assertApproxEqRel(
            joeDexLens.getTokenPriceUSD(address(newToken1)), 2.5e18, 1e16, "test_GetTokenPriceUsingFallback::6"
        );

        address pair2 = createLBPairV2_2(newToken1, USDC, ID_10_25bp);
        addLiquidityV2_2(pair2, 1000e8, 100e6);

        assertApproxEqRel(
            joeDexLens.getTokenPriceUSD(address(newToken1)),
            uint256(2.5e18 + 10e18) / 2,
            1e16,
            "test_GetTokenPriceUsingFallback::7"
        );
    }

    function test_revert_BadDataFeeds() public {
        joeDexLens.addDataFeed(USDT, IJoeDexLens.DataFeed(wNative, BNB_USDT_10BP, 1000, IJoeDexLens.DataFeedType.V2_2));

        // Revert if trying to add the same data feed again (same token and same pair)
        vm.expectRevert();
        joeDexLens.addDataFeed(USDT, IJoeDexLens.DataFeed(wNative, BNB_USDT_10BP, 1000, IJoeDexLens.DataFeedType.V2_2));

        address newToken = address(new ERC20MockDecimals(18));
        vm.expectRevert(IJoeDexLens.JoeDexLens__InvalidDataFeed.selector);
        joeDexLens.addDataFeed(USDC, IJoeDexLens.DataFeed(address(newToken), address(0), 1000, IJoeDexLens.DataFeedType.V2_2));
    }

    function test_revert_AddingUnsetVersions() public {
        joeDexLens = new JoeDexLens(ILBFactory(address(0)), lbFactory, ILBLegacyFactory(address(0)), IJoeFactory(address(0)), wNative);

        vm.expectRevert(IJoeDexLens.JoeDexLens__V2_2ContractNotSet.selector);
        joeDexLens.addDataFeed(
            address(0), IJoeDexLens.DataFeed(address(1), address(2), 1000, IJoeDexLens.DataFeedType.V2_2)
        );
        
        joeDexLens = new JoeDexLens(lbFactory, ILBFactory(address(0)), ILBLegacyFactory(address(0)), IJoeFactory(address(0)), wNative);

        vm.expectRevert(IJoeDexLens.JoeDexLens__V2_1ContractNotSet.selector);
        joeDexLens.addDataFeed(
            address(0), IJoeDexLens.DataFeed(address(1), address(2), 1000, IJoeDexLens.DataFeedType.V2_1)
        );

        joeDexLens = new JoeDexLens(lbFactory, lbFactory, ILBLegacyFactory(address(0)), IJoeFactory(address(0)), wNative);

        vm.expectRevert(IJoeDexLens.JoeDexLens__V2ContractNotSet.selector);
        joeDexLens.addDataFeed(address(0), IJoeDexLens.DataFeed(address(1), address(2), 1000, IJoeDexLens.DataFeedType.V2));

        joeDexLens = new JoeDexLens(lbFactory, lbFactory, ILBLegacyFactory(address(0)), IJoeFactory(address(0)), wNative);

        vm.expectRevert(IJoeDexLens.JoeDexLens__V1ContractNotSet.selector);
        joeDexLens.addDataFeed(address(0), IJoeDexLens.DataFeed(address(1), address(2), 1000, IJoeDexLens.DataFeedType.V1));

        vm.expectRevert(IJoeDexLens.JoeDexLens__ZeroAddress.selector);
        new JoeDexLens(lbFactory, lbFactory, ILBLegacyFactory(address(0)), IJoeFactory(address(0)), address(0));

        vm.expectRevert(IJoeDexLens.JoeDexLens__ZeroAddress.selector);
        new JoeDexLens(
            ILBFactory(address(0)),
            ILBFactory(address(0)),
            ILBLegacyFactory(address(0)),
            IJoeFactory(address(0)),
            wNative
        );
    }
}
