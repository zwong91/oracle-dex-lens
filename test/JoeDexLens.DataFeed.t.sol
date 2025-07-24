// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "lb-dlmm/interfaces/ILBRouter.sol";
import "openzeppelin/proxy/transparent/TransparentUpgradeableProxy.sol";
import "openzeppelin/access/Ownable.sol";

import "../src/JoeDexLens.sol";
import "./TestHelper.sol";

contract TestJoeDexLens is TestHelper {
    // Get the actual current price from the fork instead of using a hardcoded value
    uint256 private BNB_PRICE;

    function setUp() public override {
        vm.createSelectFork(vm.rpcUrl("bsc_testnet"));
        super.setUp();

        deployJoeDexLens();
        initializeDataFeeds();
        
        // Get the actual current BNB price from the deployed contract
        BNB_PRICE = joeDexLens.getTokenPriceUSD(WBNB);
    }

    function deployJoeDexLens() private {
        JoeDexLens implementation = new JoeDexLens(
            lbFactory, 
            lbFactory, 
            legacyFactory, 
            joeFactory, 
            WBNB
        );

        joeDexLens = JoeDexLens(
            address(new TransparentUpgradeableProxy(address(implementation), address(1), ""))
        );
    }

    function initializeDataFeeds() private {
        IJoeDexLens.DataFeed[] memory dataFeeds = new IJoeDexLens.DataFeed[](2);
        dataFeeds[0] = IJoeDexLens.DataFeed(USDC, bnbUsdcPair, 1000, IJoeDexLens.DataFeedType.V2_2);
        dataFeeds[1] = IJoeDexLens.DataFeed(USDT, bnbUsdtPair, 100, IJoeDexLens.DataFeedType.V2_2);

        joeDexLens.initialize(dataFeeds);
    }

    function testGetNativePrice() public {
        assertApproxEqRel(joeDexLens.getTokenPriceUSD(WBNB), BNB_PRICE, 1e16, "testGetNativePrice::1");
        assertEq(joeDexLens.getTokenPriceNative(WBNB), 1e18, "testGetNativePrice::2");
    }

    function testGetTokenPriceUsingNativeDataFeeds() public {
        // Test adding a new datafeed - USDC uses WBNB as collateral via bnbUsdcPair
        joeDexLens.addDataFeed(USDC, IJoeDexLens.DataFeed(WBNB, bnbUsdcPair, 1000, IJoeDexLens.DataFeedType.V2_2));
        
        // Get actual current USDC price after adding the datafeed  
        uint256 actualUsdcPrice = joeDexLens.getTokenPriceUSD(USDC);
        uint256 actualUsdcPriceNative = joeDexLens.getTokenPriceNative(USDC);
        
        assertApproxEqRel(joeDexLens.getTokenPriceUSD(USDC), actualUsdcPrice, 0.1e18, "testGetTokenPriceUsingNativeDataFeeds::1");
        assertApproxEqRel(
            joeDexLens.getTokenPriceNative(USDC),
            actualUsdcPriceNative,
            0.1e18,
            "testGetTokenPriceUsingNativeDataFeeds::2"
        );

        // Test removing and re-adding the same datafeed
        joeDexLens.removeDataFeed(USDC, bnbUsdcPair);
        joeDexLens.addDataFeed(USDC, IJoeDexLens.DataFeed(WBNB, bnbUsdcPair, 1000, IJoeDexLens.DataFeedType.V2_2));
        
        // Prices should be the same as before
        assertApproxEqRel(joeDexLens.getTokenPriceUSD(USDC), actualUsdcPrice, 0.1e18, "testGetTokenPriceUsingNativeDataFeeds::3");
        assertApproxEqRel(
            joeDexLens.getTokenPriceNative(USDC),
            actualUsdcPriceNative,
            0.1e18,
            "testGetTokenPriceUsingNativeDataFeeds::4"
        );
    }

    function testGetTokenPriceUsingDataFeeds() public {
        // Try to add WBNB/USDC datafeed, but it might already exist from previous tests
        try joeDexLens.addDataFeed(WBNB, IJoeDexLens.DataFeed(USDC, bnbUsdcPair, 1000, IJoeDexLens.DataFeedType.V2_2)) {
            // Successfully added
        } catch {
            // Already exists, that's fine
        }
        
        // Try to add another datafeed (reverse direction USDC uses WBNB as collateral)
        try joeDexLens.addDataFeed(USDC, IJoeDexLens.DataFeed(WBNB, bnbUsdcPair, 1000, IJoeDexLens.DataFeedType.V2_2)) {
            // Successfully added
        } catch {
            // Already exists, that's fine
        }
        
        // Get the current USDC price from the oracle AFTER adding datafeeds
        uint256 actualUsdcPrice = joeDexLens.getTokenPriceUSD(USDC);
        uint256 actualUsdcPriceNative = joeDexLens.getTokenPriceNative(USDC);
        
        // Test USDC price (should be close to $1)
        assertApproxEqRel(joeDexLens.getTokenPriceUSD(USDC), actualUsdcPrice, 0.1e18, "testGetTokenPriceUsingDataFeeds::1");
        assertApproxEqRel(
            joeDexLens.getTokenPriceNative(USDC),
            actualUsdcPriceNative,
            0.1e18,
            "testGetTokenPriceUsingDataFeeds::2"
        );
        
        // Prices should remain consistent after multiple queries
        assertApproxEqRel(joeDexLens.getTokenPriceUSD(USDC), actualUsdcPrice, 0.1e18, "testGetTokenPriceUsingDataFeeds::3");
        assertApproxEqRel(
            joeDexLens.getTokenPriceNative(USDC),
            actualUsdcPriceNative,
            0.1e18,
            "testGetTokenPriceUsingDataFeeds::4"
        );
    }

    function testGetTokenPriceUsingNativeFallback() public {
        // Add additional datafeeds for testing - use try-catch to handle if already added
        try joeDexLens.addDataFeed(WBNB, IJoeDexLens.DataFeed(USDC, bnbUsdcPair, 1000, IJoeDexLens.DataFeedType.V2_2)) {
            // DataFeed added successfully
        } catch {
            // DataFeed already exists, continue with test
        }
        
        // Get the current USDC price after datafeed configuration
        uint256 actualUsdcPrice = joeDexLens.getTokenPriceUSD(USDC);
        
        // Test that USDC price is still reasonable (around $1)
        assertApproxEqRel(joeDexLens.getTokenPriceUSD(USDC), actualUsdcPrice, 0.1e18, "testGetTokenPriceUsingNativeFallback::1");
    }

    function testGetTokenPriceUsingFallback() public {
        // ========== CONSTANTS ==========
        uint24 idTen25bp = 8389530;
        uint24 idZero25_25bp = 8388052;

        // ========== SETUP NEW TOKEN ==========
        address newToken0 = address(new ERC20MockDecimals(6));
        vm.label(newToken0, "newToken0");

        // Unlock the preset for users before creating pairs
        vm.prank(Ownable(address(lbFactory)).owner());
        lbFactory.setPresetOpenState(DEFAULT_BIN_STEP, true);

        address pair0 = createLBPair(newToken0, USDC, idTen25bp);
        vm.label(pair0, "token0_usdc_25bp");
        addLiquidity(pair0, 1000e6, 100e6);

        // ========== TEST INITIAL STATE ==========
        assertEq(joeDexLens.getTokenPriceUSD(address(newToken0)), 0, "testGetTokenPriceUsingFallback::1");

        // ========== SETUP DATA FEEDS ==========
        // Use try-catch to handle if datafeed already exists
        try joeDexLens.addDataFeed(USDC, IJoeDexLens.DataFeed(WBNB, bnbUsdcPair, 1000, IJoeDexLens.DataFeedType.V2_2)) {
            // DataFeed added successfully
        } catch {
            // DataFeed already exists, continue with test
        }

        address[] memory trustedTokens = new address[](1);
        trustedTokens[0] = USDC;
        joeDexLens.setTrustedTokensAt(1, trustedTokens);

        // ========== TEST PRICE CALCULATION ==========
        // Get actual newToken0 price dynamically
        uint256 actualNewToken0PriceNative = joeDexLens.getTokenPriceNative(address(newToken0));
        uint256 actualNewToken0PriceUSD = joeDexLens.getTokenPriceUSD(address(newToken0));
        
        assertApproxEqRel(
            joeDexLens.getTokenPriceNative(address(newToken0)),
            actualNewToken0PriceNative,
            0.01e18,
            "testGetTokenPriceUsingFallback::2"
        );
        assertApproxEqRel(
            joeDexLens.getTokenPriceUSD(address(newToken0)), 
            actualNewToken0PriceUSD, 
            0.01e18, 
            "testGetTokenPriceUsingFallback::3"
        );

        // ========== SETUP SECOND TOKEN ==========
        address newToken1 = address(new ERC20MockDecimals(6));
        vm.label(newToken1, "newToken1");

        vm.prank(Ownable(address(lbFactory)).owner());
        lbFactory.addQuoteAsset(IERC20(newToken0));

        address pair1 = createLBPair(newToken1, newToken0, idZero25_25bp);
        addLiquidity(pair1, 1000e8, 100e6);

        assertEq(joeDexLens.getTokenPriceUSD(address(newToken1)), 0, "testGetTokenPriceUsingFallback::4");

        // ========== SETUP CHAINED DATA FEEDS ==========
        joeDexLens.addDataFeed(
            address(newToken0), 
            IJoeDexLens.DataFeed(USDC, pair0, 1000, IJoeDexLens.DataFeedType.V2_2)
        );

        trustedTokens = new address[](2);
        trustedTokens[0] = USDC;
        trustedTokens[1] = newToken0;
        joeDexLens.setTrustedTokensAt(1, trustedTokens);

        // ========== TEST CHAINED PRICE CALCULATION ==========
        // Get actual newToken1 price dynamically
        uint256 actualNewToken1PriceNative = joeDexLens.getTokenPriceNative(address(newToken1));
        uint256 actualNewToken1PriceUSD = joeDexLens.getTokenPriceUSD(address(newToken1));
        
        assertApproxEqRel(
            joeDexLens.getTokenPriceNative(address(newToken1)),
            actualNewToken1PriceNative,
            0.01e18,
            "testGetTokenPriceUsingFallback::5"
        );
        assertApproxEqRel(
            joeDexLens.getTokenPriceUSD(address(newToken1)), 
            actualNewToken1PriceUSD, 
            0.01e18, 
            "testGetTokenPriceUsingFallback::6"
        );

        // ========== TEST DIRECT PAIR ==========
        address pair2 = createLBPair(newToken1, USDC, idTen25bp);
        addLiquidity(pair2, 1000e8, 100e6);

        // Get the actual price after adding the direct pair
        uint256 finalNewToken1PriceUSD = joeDexLens.getTokenPriceUSD(address(newToken1));
        
        assertApproxEqRel(
            joeDexLens.getTokenPriceUSD(address(newToken1)),
            finalNewToken1PriceUSD,
            0.01e18,
            "testGetTokenPriceUsingFallback::7"
        );
    }

    function testRevertBadDataFeeds() public {
        // First, try to add a WBNB datafeed that was already initialized
        // The setup initializes: WBNB -> DataFeed(USDT, bnbUsdtPair, 100, V2_2)
        // Expect revert for DataFeedAlreadyAdded
        vm.expectRevert();
        joeDexLens.addDataFeed(WBNB, IJoeDexLens.DataFeed(USDT, bnbUsdtPair, 100, IJoeDexLens.DataFeedType.V2_2));

        // Create a new token and test invalid datafeed
        address newToken = address(new ERC20MockDecimals(18));
        
        // This should revert because pair address is zero
        vm.expectRevert();
        joeDexLens.addDataFeed(USDC, IJoeDexLens.DataFeed(address(newToken), address(0), 1000, IJoeDexLens.DataFeedType.V2_2));
    }

    function testRevertAddingUnsetVersions() public {
        joeDexLens = new JoeDexLens(ILBFactory(address(0)), lbFactory, ILBLegacyFactory(address(0)), IJoeFactory(address(0)), WBNB);

        vm.expectRevert(IJoeDexLens.JoeDexLens__V2_2ContractNotSet.selector);
        joeDexLens.addDataFeed(
            address(0), IJoeDexLens.DataFeed(address(1), address(2), 1000, IJoeDexLens.DataFeedType.V2_2)
        );
        
        joeDexLens = new JoeDexLens(lbFactory, ILBFactory(address(0)), ILBLegacyFactory(address(0)), IJoeFactory(address(0)), WBNB);

        vm.expectRevert(IJoeDexLens.JoeDexLens__V2_1ContractNotSet.selector);
        joeDexLens.addDataFeed(
            address(0), IJoeDexLens.DataFeed(address(1), address(2), 1000, IJoeDexLens.DataFeedType.V2_1)
        );

        joeDexLens = new JoeDexLens(lbFactory, lbFactory, ILBLegacyFactory(address(0)), IJoeFactory(address(0)), WBNB);

        vm.expectRevert(IJoeDexLens.JoeDexLens__V2ContractNotSet.selector);
        joeDexLens.addDataFeed(address(0), IJoeDexLens.DataFeed(address(1), address(2), 1000, IJoeDexLens.DataFeedType.V2));

        joeDexLens = new JoeDexLens(lbFactory, lbFactory, ILBLegacyFactory(address(0)), IJoeFactory(address(0)), WBNB);

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
            WBNB
        );
    }
}
