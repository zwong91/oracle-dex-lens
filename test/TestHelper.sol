// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "lb-dlmm/interfaces/ILBRouter.sol";
import "lb-dlmm/interfaces/ILBFactory.sol";
import "lb-dlmm/interfaces/IJoeRouter02.sol";
import "lb-dlmm/LBPair.sol";
import "lb-dlmm/LBRouter.sol";
import "lb-dlmm/LBFactory.sol";
import "openzeppelin/token/ERC20/IERC20.sol";
import "openzeppelin/access/Ownable.sol";

import "../src/JoeDexLens.sol";
import "../src/interfaces/AggregatorV3Interface.sol";
import "./mocks/ERC20MockDecimals.sol";
import "./mocks/MockAggregator.sol";

abstract contract TestHelper is Test {
    using Uint256x256Math for uint256;

    // ========== CUSTOM ERRORS ==========
    error InvalidAmount();

    // ========== ADDRESSES ==========
    address payable internal immutable DEV = payable(address(this));
    address internal immutable ALICE = makeAddr("alice");
    
    address public constant TOKEN_OWNER = 0xE0A051f87bb78f38172F633449121475a193fC1A;
    address public constant FACTORY_OWNER = 0xE0A051f87bb78f38172F633449121475a193fC1A;
    address public constant BNB_DATA_FEED = 0x143db3CEEfbdfe5631aDD3E50f7614B6ba708BA7;

    // ========== FACTORY INSTANCES ==========
    ILBRouter public constant LB_ROUTER = ILBRouter(0xe98efCE22A8Ec0dd5dDF6C1A81B6ADD740176E98);
    ILBFactory public lbFactory = ILBFactory(0x7D73A6eFB91C89502331b2137c2803408838218b);
    ILBLegacyFactory public legacyFactory = ILBLegacyFactory(address(0));
    IJoeFactory public joeFactory = IJoeFactory(address(0));

    // ========== TOKENS ==========
    address public constant USDT = 0x337610d27c682E347C9cD60BD4b3b107C9d34dDd;
    address public constant USDC = 0x64544969ed7EBf5f083679233325356EbE738930;
    address public constant WETH = 0x8BaBbB98678facC7342735486C851ABD7A0d17Ca;
    address public constant WBNB = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;

    // ========== LB PAIR CONSTANTS ==========
    uint8 internal constant DEFAULT_BIN_STEP = 25;
    uint16 internal constant DEFAULT_BASE_FACTOR = 5_000;
    uint16 internal constant DEFAULT_FILTER_PERIOD = 30;
    uint16 internal constant DEFAULT_DECAY_PERIOD = 600;
    uint16 internal constant DEFAULT_REDUCTION_FACTOR = 5_000;
    uint24 internal constant DEFAULT_VARIABLE_FEE_CONTROL = 40_000;
    uint16 internal constant DEFAULT_PROTOCOL_SHARE = 1_000;
    uint24 internal constant DEFAULT_MAX_VOLATILITY_ACCUMULATOR = 350_000;
    uint256 internal constant DEFAULT_FLASHLOAN_FEE = 8e14;
    uint24 internal constant ID_ONE = 2 ** 23;

    // Liquidity Pool Pairs
    address public bnbUsdcPair;
    address public bnbUsdtPair;
    address public usdcUsdtPair;

    JoeDexLens public joeDexLens;

    function setUp() public virtual {
        setupLabels();
        createLiquidityPairs();
    }

    function setupLabels() private {
        vm.label(address(lbFactory), "LBFactory");
        vm.label(address(LB_ROUTER), "LBRouter");
        
        vm.label(USDC, "USDC");
        vm.label(USDT, "USDT");
        vm.label(WETH, "WETH");
        vm.label(WBNB, "WBNB");
    }

    function createLiquidityPairs() private {
        bnbUsdcPair = getOrCreatePair(WBNB, USDC, ID_ONE, "WBNB/USDC");
        bnbUsdtPair = getOrCreatePair(WBNB, USDT, ID_ONE - 1000, "WBNB/USDT");
        usdcUsdtPair = getOrCreatePair(USDC, USDT, ID_ONE + 1000, "USDC/USDT");
    }

    function getOrCreatePair(
        address tokenA, 
        address tokenB, 
        uint24 binId, 
        string memory pairName
    ) private returns (address pair) {
        // Check if pair already exists
        pair = address(lbFactory.getLBPairInformation(IERC20(tokenA), IERC20(tokenB), DEFAULT_BIN_STEP).LBPair);
        
        if (pair == address(0)) {
            // Pair doesn't exist, create it
            pair = createLBPair(tokenA, tokenB, binId);
        }
        
        vm.label(pair, pairName);
    }

    function createLBPair(address tokenA, address tokenB, uint24 binId) internal returns (address) {
        return address(lbFactory.createLBPair(IERC20(tokenA), IERC20(tokenB), binId, DEFAULT_BIN_STEP));
    }

    function addLiquidity(address pairAddress, uint256 amountX, uint256 amountY) internal {
        if (amountX == 0 || amountY == 0) revert InvalidAmount();

        ILBPair pair = ILBPair(pairAddress);
        IERC20 tokenX = pair.getTokenX();
        IERC20 tokenY = pair.getTokenY();
        uint24 activeId = pair.getActiveId();

        // Approve tokens for router
        tokenX.approve(address(LB_ROUTER), amountX);
        tokenY.approve(address(LB_ROUTER), amountY);

        // Deal tokens to pair
        deal(address(tokenX), pairAddress, tokenX.balanceOf(pairAddress) + amountX);
        deal(address(tokenY), pairAddress, tokenY.balanceOf(pairAddress) + amountY);

        // Create liquidity configuration
        bytes32[] memory liquidityConfig = createLiquidityConfig(activeId);
        
        // Mint liquidity
        pair.mint(DEV, liquidityConfig, DEV);
    }

    function createLiquidityConfig(uint24 activeId) private pure returns (bytes32[] memory) {
        bytes32[] memory config = new bytes32[](9);

        for (uint24 i = 0; i < 9; i++) {
            uint24 binId = activeId - 4 + i;
            uint64 distribX = binId >= activeId ? 0.2e18 : 0;
            uint64 distribY = binId <= activeId ? 0.2e18 : 0;
            
            config[i] = LiquidityConfigurations.encodeParams(distribX, distribY, binId);
        }
        
        return config;
    }
}