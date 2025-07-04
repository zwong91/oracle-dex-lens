#!/bin/bash

# JoeDexLens Contract Interaction Script
# BSC Testnet Deployment

source .env

# Function to convert wei to readable format
convert_wei_to_readable() {
    local wei_value=$1
    if command -v cast >/dev/null 2>&1; then
        cast to-unit $wei_value ether 2>/dev/null || echo "cast_failed"
    elif command -v python3 >/dev/null 2>&1; then
        python3 -c "print(f'{$wei_value / 10**18:.6f}')"
    elif command -v bc >/dev/null 2>&1; then
        echo "scale=6; $wei_value / 1000000000000000000" | bc 2>/dev/null || echo "calc_failed"
    else
        echo "install_cast_python3_or_bc"
    fi
}

# Contract address
JOEDEXLENS_PROXY="0x8C7dc8184F5D78Aa40430b2d37f78fDC3e9A9b78"

# Token addresses on BSC Testnet
WBNB="0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd"
USDC="0x64544969ed7EBf5f083679233325356EbE738930"
USDT="0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684"

echo "=== JoeDexLens Contract Call Examples ==="
echo "Contract Address: $JOEDEXLENS_PROXY"
echo "Network: BSC Testnet"
echo

echo "1. Getting WNative Address:"
wNative=$(cast call $JOEDEXLENS_PROXY "getWNative()" --rpc-url bsc_testnet)
wNativeAddr=$(cast abi-decode "getWNative()(address)" $wNative)
echo "   WNative Address: $wNativeAddr"
echo

echo "2. Getting WBNB Price in Native (should be 1):"
wbnbNativePrice=$(cast call $JOEDEXLENS_PROXY "getTokenPriceNative(address)" $WBNB --rpc-url bsc_testnet)
wbnbNativePriceDecoded=$(cast abi-decode "getTokenPriceNative(address)(uint256)" $wbnbNativePrice)
echo "   WBNB/Native Price: $wbnbNativePriceDecoded (raw: 1e18 = 1.0)"
echo

echo "3. Getting WBNB Price in USD:"
wbnbUSDPrice=$(cast call $JOEDEXLENS_PROXY "getTokenPriceUSD(address)" $WBNB --rpc-url bsc_testnet)
wbnbUSDPriceDecoded=$(cast abi-decode "getTokenPriceUSD(address)(uint256)" $wbnbUSDPrice)
echo "   WBNB/USD Price: $wbnbUSDPriceDecoded"
readable_price=$(convert_wei_to_readable $wbnbUSDPriceDecoded)
echo "   Converted to readable format: $readable_price USD"
echo

echo "4. Testing other tokens (may fail if no liquidity pools exist):"

echo "   Trying USDC Native Price..."
if usdcNativePrice=$(cast call $JOEDEXLENS_PROXY "getTokenPriceNative(address)" $USDC --rpc-url bsc_testnet 2>/dev/null); then
    usdcNativePriceDecoded=$(cast abi-decode "getTokenPriceNative(address)(uint256)" $usdcNativePrice)
    echo "   USDC/Native Price: $usdcNativePriceDecoded"
    readable_usdc_price=$(convert_wei_to_readable $usdcNativePriceDecoded)
    echo "   USDC readable format: $readable_usdc_price USD"
else
    echo "   USDC/Native Price: Failed (no liquidity or data feed)"
fi

echo "   Trying USDT Native Price..."
if usdtNativePrice=$(cast call $JOEDEXLENS_PROXY "getTokenPriceNative(address)" $USDT --rpc-url bsc_testnet 2>/dev/null); then
    usdtNativePriceDecoded=$(cast abi-decode "getTokenPriceNative(address)(uint256)" $usdtNativePrice)
    echo "   USDT/Native Price: $usdtNativePriceDecoded"
else
    echo "   USDT/Native Price: Failed (no liquidity or data feed)"
fi
echo

echo "5. Available Functions:"
echo "   - getWNative() -> address"
echo "   - getTokenPriceNative(address) -> uint256" 
echo "   - getTokenPriceUSD(address) -> uint256"
echo "   - getTokensPricesNative(address[]) -> uint256[]"
echo "   - getTokensPricesUSD(address[]) -> uint256[]"
echo "   - getDataFeeds(address) -> DataFeed[]"
echo

echo "=== Manual Usage Examples ==="
echo "Get token price in native:"
echo "cast call $JOEDEXLENS_PROXY \"getTokenPriceNative(address)\" <TOKEN_ADDRESS> --rpc-url bsc_testnet"
echo
echo "Get token price in USD:"
echo "cast call $JOEDEXLENS_PROXY \"getTokenPriceUSD(address)\" <TOKEN_ADDRESS> --rpc-url bsc_testnet"
echo
echo "Get WNative address:"
echo "cast call $JOEDEXLENS_PROXY \"getWNative()\" --rpc-url bsc_testnet"
echo

echo "=== Price Conversion Helper ==="
echo "To convert wei to readable format (18 decimals):"
echo ""
echo "Method 1 - Using Python (recommended):"
echo "python3 -c \"print(f'{PRICE_IN_WEI / 10**18:.6f}')\""
echo ""
echo "Method 2 - Using bc calculator:"
echo "echo \"scale=6; PRICE_IN_WEI / 1000000000000000000\" | bc"
echo ""
echo "Method 3 - Using cast (for on-chain calculations):"
echo "cast to-unit PRICE_IN_WEI ether"
