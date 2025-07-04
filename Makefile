# Makefile for JoeDexLens project

# 从 .env 文件中读取变量
ifeq (,$(wildcard .env))
$(error .env file not found)
endif

include .env
export

.PHONY: all build clean test deploy verify call-joedexlens add-datafeeds debug-contract test-chainlink

all: build

build:
	forge build

clean:
	forge clean

test:
	forge test -vvv

deploy:
	forge script script/deploy.s.sol:Deploy --rpc-url bsc_testnet --broadcast

verify:
	forge script script/deploy.s.sol:Deploy --rpc-url bsc_testnet --verify --etherscan-api-key $$ETHERSCAN_API_KEY

# Forge script version (limited output due to forge limitations)
call-joedexlens-forge:
	forge script script/call-joedexlens.s.sol:CallJoeDexLens --fork-url https://data-seed-prebsc-1-s1.bnbchain.org:8545

# Cast version (recommended - full output)
call-joedexlens:
	@echo "=== JoeDexLens Contract Test (Cast Version) ==="
	@echo "Contract: 0x8C7dc8184F5D78Aa40430b2d37f78fDC3e9A9b78"
	@echo ""
	@echo "1. WNative Address:"
	@cast call 0x8C7dc8184F5D78Aa40430b2d37f78fDC3e9A9b78 "getWNative()" --rpc-url bsc_testnet | xargs cast abi-decode "getWNative()(address)"
	@echo ""
	@echo "2. WBNB Prices:"
	@echo -n "   Native Price: "
	@cast call 0x8C7dc8184F5D78Aa40430b2d37f78fDC3e9A9b78 "getTokenPriceNative(address)" 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd --rpc-url bsc_testnet | xargs cast abi-decode "getTokenPriceNative(address)(uint256)"
	@echo -n "   USD Price: "
	@cast call 0x8C7dc8184F5D78Aa40430b2d37f78fDC3e9A9b78 "getTokenPriceUSD(address)" 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd --rpc-url bsc_testnet | xargs cast abi-decode "getTokenPriceUSD(address)(uint256)"
	@echo ""
	@echo "3. USDC Prices:"
	@echo -n "   Native Price: "
	@cast call 0x8C7dc8184F5D78Aa40430b2d37f78fDC3e9A9b78 "getTokenPriceNative(address)" 0x64544969ed7EBf5f083679233325356EbE738930 --rpc-url bsc_testnet | xargs cast abi-decode "getTokenPriceNative(address)(uint256)"
	@echo -n "   USD Price: "
	@cast call 0x8C7dc8184F5D78Aa40430b2d37f78fDC3e9A9b78 "getTokenPriceUSD(address)" 0x64544969ed7EBf5f083679233325356EbE738930 --rpc-url bsc_testnet | xargs cast abi-decode "getTokenPriceUSD(address)(uint256)"
	@echo ""
	@echo "4. USDT Prices:"
	@echo -n "   Native Price: "
	@cast call 0x8C7dc8184F5D78Aa40430b2d37f78fDC3e9A9b78 "getTokenPriceNative(address)" 0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684 --rpc-url bsc_testnet | xargs cast abi-decode "getTokenPriceNative(address)(uint256)"
	@echo -n "   USD Price: "
	@cast call 0x8C7dc8184F5D78Aa40430b2d37f78fDC3e9A9b78 "getTokenPriceUSD(address)" 0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684 --rpc-url bsc_testnet | xargs cast abi-decode "getTokenPriceUSD(address)(uint256)"
	@echo ""
	@echo "=== Test Complete (use ./call-joedexlens.sh for formatted output) ==="

add-datafeeds:
	forge script script/add-datafeeds.s.sol:AddDataFeeds --rpc-url bsc_testnet --broadcast

debug-contract:
	forge script script/debug-contract.s.sol:DebugContract --rpc-url bsc_testnet

test-chainlink:
	forge script script/test-chainlink.s.sol:TestChainlink --rpc-url bsc_testnet

test-bnb-only:
	forge script script/test-bnb-only.s.sol:TestBNBOnly --rpc-url bsc_testnet

test-chainlink-raw:
	forge script script/test-chainlink-raw.s.sol:TestChainlinkRaw --rpc-url bsc_testnet

cast-test:
	@echo "=== Cast-based JoeDexLens Test ==="
	@echo "WBNB Native Price:"
	@cast call 0x8C7dc8184F5D78Aa40430b2d37f78fDC3e9A9b78 "getTokenPriceNative(address)" 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd --rpc-url bsc_testnet
	@echo "WBNB USD Price:"
	@cast call 0x8C7dc8184F5D78Aa40430b2d37f78fDC3e9A9b78 "getTokenPriceUSD(address)" 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd --rpc-url bsc_testnet
	@echo "USDC Native Price:"
	@cast call 0x8C7dc8184F5D78Aa40430b2d37f78fDC3e9A9b78 "getTokenPriceNative(address)" 0x64544969ed7EBf5f083679233325356EbE738930 --rpc-url bsc_testnet
