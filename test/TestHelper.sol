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

import "../src/JoeDexLens.sol";
import "../src/interfaces/AggregatorV3Interface.sol";
import "./mocks/ERC20MockDecimals.sol";
import "./mocks/MockAggregator.sol";

abstract contract TestHelper is Test {
    using Uint256x256Math for uint256;

    address payable internal immutable DEV = payable(address(this));
    address internal immutable ALICE = makeAddr("alice");

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

    address public constant tokenOwner = 0xE0A051f87bb78f38172F633449121475a193fC1A;
    address public constant factoryOwner = 0xE0A051f87bb78f38172F633449121475a193fC1A;
    address public constant bnbDataFeed = 0x0A77230d17318075983913bC2145DB16C7366156;

    ILBRouter public constant lbRouter = ILBRouter(0xe98efCE22A8Ec0dd5dDF6C1A81B6ADD740176E98);
    ILBFactory public lbFactory = ILBFactory(0x7D73A6eFB91C89502331b2137c2803408838218b);

    address public constant USDT = 0x7Ef95a0fEE0bF6Ff3bB2BA9Ba3bF8C7cA7Ef7E7A;
    address public constant USDC = 0x64544969ed7EBf5f083679233325356EbE738930;
    address public constant WETH = 0x8BaBbB98678facC7342735486C851ABD7A0d17Ca;
    address public constant wNative = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;

    address public constant BNB_USDC_25BP = 0x5E4c51ab2EAa2fa9dB25Ea4638FfEF3c017Db34B; // WBNB/USDC 25BP
    address public constant BNB_USDT_10BP = 0x406Ca3B0acD27b8060c84902d2B0CAB6F5Ad898D; // WBNB/USDT 10BP
    address public constant USDC_USDT_1BP = 0xEC5255Ca9De7280439366F90ec29b03461EA5027; // USDC/USDT 1BP


    JoeDexLens public joeDexLens;

    function setUp() public virtual {
        vm.label(address(lbFactory), "factory");
        vm.label(address(lbRouter), "router");

        vm.label(USDC, "usdc");
        vm.label(USDT, "usdt");
        vm.label(WETH, "weth");
        vm.label(wNative, "wNative");

        vm.label(BNB_USDC_25BP, "bnb_usdc_25bp");
        vm.label(BNB_USDT_10BP, "bnb_usdt_10bp");
        vm.label(USDC_USDT_1BP, "usdc_usdt_1bp");
    }

    function createLBPairV2_2(address tokenA, address quoteToken, uint24 id) internal returns (address) {
        return address(lbFactory.createLBPair(IERC20(tokenA), IERC20(quoteToken), id, DEFAULT_BIN_STEP));
    }

    function addLiquidityV2_2(address pair, uint256 amountX, uint256 amountY) internal {
        require(amountX > 0 && amountY > 0, "TestHelper: amount must be greater than 0");

        IERC20 tokenX = ILBPair(pair).getTokenX();
        IERC20 tokenY = ILBPair(pair).getTokenY();
        uint24 activeId = ILBPair(pair).getActiveId();

        tokenX.approve(address(lbRouter), amountX);
        tokenY.approve(address(lbRouter), amountY);

        deal(address(tokenX), pair, tokenX.balanceOf(pair) + amountX);
        deal(address(tokenY), pair, tokenY.balanceOf(pair) + amountY);

        bytes32[] memory config = new bytes32[](9);

        for (uint24 i = 0; i < 9; i++) {
            uint24 id = activeId - 4 + i;

            uint64 distribX = id >= activeId ? 0.2e18 : 0;
            uint64 distribY = id <= activeId ? 0.2e18 : 0;

            config[i] = LiquidityConfigurations.encodeParams(distribX, distribY, id);
        }

        ILBPair(pair).mint(DEV, config, DEV);
    }
}