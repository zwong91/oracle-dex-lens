# Makefile for OracleDexLens project

# 从 .env 文件中读取变量
ifeq (,$(wildcard .env))
$(error .env file not found)
endif

include .env
export

<<<<<<< HEAD
.PHONY: all build clean test deploy-testnet deploy-mainnet call-joedexlens debug-contract test-chainlink
=======
.PHONY: all build clean test deploy deploy-testnet deploy-chapel deploy-mainnet call-dexlens add-datafeeds add-datafeeds-testnet debug-contract test-chainlink info
>>>>>>> 262e00e (Add OracleDexLens documentation, scripts, and update contract references)

all: build

build:
	forge build

clean:
	forge clean

test:
	forge test -vvvv

<<<<<<< HEAD
deploy-testnet:
	NETWORK=testnet forge script script/deploy.s.sol:Deploy --rpc-url https://bsc-testnet.public.blastapi.io --broadcast --verify --etherscan-api-key $$ETHERSCAN_API_KEY

deploy-mainnet:
	NETWORK=mainnet forge script script/deploy.s.sol:Deploy --rpc-url https://bsc-dataseed.bnbchain.org --broadcast --verify --etherscan-api-key $$ETHERSCAN_API_KEY
=======
# Show deployment info
info:
	@echo "=== OracleDexLens Deployment Information ==="
	@echo ""
	@echo "Available networks:"
	@echo "  - Testnet: BSC Testnet (Chain ID: 97)"
	@echo "  - Mainnet: BSC Mainnet (Chain ID: 56)"
	@echo ""
	@echo "Deployment commands:"
	@echo "  make deploy-testnet                     - Deploy OracleDexLens to BSC Testnet"
	@echo "  make deploy-mainnet                     - Deploy OracleDexLens to BSC Mainnet"
	@echo "  make deploy-inverse-aggregator-testnet  - Deploy InverseWBNBAggregator to testnet"
	@echo "  make deploy-inverse-aggregator-mainnet  - Deploy InverseWBNBAggregator to mainnet"
	@echo "  make add-datafeeds-testnet              - Add data feeds to testnet"
	@echo "  make add-datafeeds-mainnet              - Add data feeds to mainnet"
	@echo "  make verify-datafeeds-testnet           - Verify data feeds on testnet"
	@echo "  make verify-datafeeds-mainnet           - Verify data feeds on mainnet"
	@echo ""
	@echo "Configuration files:"
	@echo "  script/config/deployments.json - Network configurations"
	@echo ""
	@echo "Deployed contracts:"
	@echo "  BSC Testnet:"
	@echo "    - InverseWBNBAggregator: 0x440d1926FF183423EDC84a803f888915A1CDD8df"
	@echo "  BSC Mainnet:"
	@echo "    - InverseWBNBAggregator: 0xA89fe2F67d78F26F077E2811b2948399A4e5aF0A"
	@echo ""

deploy-chapel:
	TARGET_NETWORK=testnet forge script script/deploy.s.sol:Deploy --rpc-url bsc_testnet --broadcast --verify --etherscan-api-key $$ETHERSCAN_API_KEY

deploy-mainnet:
	TARGET_NETWORK=mainnet forge script script/deploy.s.sol:Deploy --rpc-url https://bsc-dataseed.bnbchain.org --broadcast --verify --etherscan-api-key $$ETHERSCAN_API_KEY

# New convenience targets
deploy-testnet: deploy-chapel

deploy:
	@echo "Usage: make deploy-testnet or make deploy-mainnet"

# Unified data feeds management (auto-detects network)
add-datafeeds-mainnet:
	forge script script/add-datafeeds.s.sol:AddDataFeeds --rpc-url https://bsc-dataseed.bnbchain.org --broadcast

add-datafeeds-testnet:
	forge script script/add-datafeeds.s.sol:AddDataFeeds --rpc-url bsc_testnet --broadcast

# Default to testnet for backwards compatibility
add-datafeeds: add-datafeeds-testnet

# Deploy the inverse WBNB aggregator
deploy-inverse-aggregator-mainnet:
	forge script script/deploy-inverse-aggregator.s.sol:DeployInverseAggregator --rpc-url https://bsc-dataseed.bnbchain.org --broadcast --verify --etherscan-api-key $$ETHERSCAN_API_KEY

deploy-inverse-aggregator-testnet:
	forge script script/deploy-inverse-aggregator.s.sol:DeployInverseAggregator --rpc-url bsc_testnet --broadcast --verify --etherscan-api-key $$ETHERSCAN_API_KEY

# Default to testnet for backwards compatibility
deploy-inverse-aggregator: deploy-inverse-aggregator-testnet

# Verify data feeds (auto-detects network)
verify-datafeeds-mainnet:
	forge script script/verify-datafeeds.s.sol --rpc-url https://bsc-dataseed.bnbchain.org

verify-datafeeds-testnet:
	forge script script/verify-datafeeds.s.sol --rpc-url bsc_testnet

verify-datafeeds: verify-datafeeds-testnet

# Forge script version (limited output due to forge limitations)
call-dexlens-forge:
	forge script script/call-dexlens.s.sol:CallJoeDexLens --rpc-url bsc_testnet

# Cast version (recommended - full output)
call-dexlens:
	@echo "=== OracleDexLens Contract Test (Cast Version) ==="
	@echo "Contract: 0xb512457fcB3020dC4a62480925B68dc83E776340"
	@echo ""
	@echo "1. WNative Address:"
	@cast call 0xb512457fcB3020dC4a62480925B68dc83E776340 "getWNative()" --rpc-url bsc_testnet | xargs cast abi-decode "getWNative()(address)"
	@echo ""
	@echo "2. WBNB Prices:"
	@echo -n "   Native Price: "
	@cast call 0xb512457fcB3020dC4a62480925B68dc83E776340 "getTokenPriceNative(address)" 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd --rpc-url bsc_testnet | xargs cast abi-decode "getTokenPriceNative(address)(uint256)"
	@echo -n "   USD Price: "
	@cast call 0xb512457fcB3020dC4a62480925B68dc83E776340 "getTokenPriceUSD(address)" 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd --rpc-url bsc_testnet | xargs cast abi-decode "getTokenPriceUSD(address)(uint256)"
	@echo ""
	@echo "3. USDC Prices:"
	@echo -n "   Native Price: "
	@cast call 0xb512457fcB3020dC4a62480925B68dc83E776340 "getTokenPriceNative(address)" 0x64544969ed7EBf5f083679233325356EbE738930 --rpc-url bsc_testnet | xargs cast abi-decode "getTokenPriceNative(address)(uint256)"
	@echo -n "   USD Price: "
	@cast call 0xb512457fcB3020dC4a62480925B68dc83E776340 "getTokenPriceUSD(address)" 0x64544969ed7EBf5f083679233325356EbE738930 --rpc-url bsc_testnet | xargs cast abi-decode "getTokenPriceUSD(address)(uint256)"
	@echo ""
	@echo "4. USDT Prices:"
	@echo -n "   Native Price: "
	@cast call 0xb512457fcB3020dC4a62480925B68dc83E776340 "getTokenPriceNative(address)" 0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684 --rpc-url bsc_testnet | xargs cast abi-decode "getTokenPriceNative(address)(uint256)"
	@echo -n "   USD Price: "
	@cast call 0xb512457fcB3020dC4a62480925B68dc83E776340 "getTokenPriceUSD(address)" 0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684 --rpc-url bsc_testnet | xargs cast abi-decode "getTokenPriceUSD(address)(uint256)"
	@echo ""
	@echo "=== Test Complete (use ./call-dexlens.sh for formatted output) ==="

debug-contract:
	forge script script/debug-contract.s.sol:DebugContract --rpc-url bsc_testnet

test-chainlink:
	forge script script/test-chainlink.s.sol:TestChainlink --rpc-url bsc_testnet

test-bnb-only:
	forge script script/test-bnb-only.s.sol:TestBNBOnly --rpc-url bsc_testnet

test-chainlink-raw:
	forge script script/test-chainlink-raw.s.sol:TestChainlinkRaw --rpc-url bsc_testnet

cast-test:
	@echo "=== Cast-based OracleDexLens Test ==="
	@echo "WBNB Native Price:"
	@cast call 0xb512457fcB3020dC4a62480925B68dc83E776340 "getTokenPriceNative(address)" 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd --rpc-url bsc_testnet
	@echo "WBNB USD Price:"
	@cast call 0xb512457fcB3020dC4a62480925B68dc83E776340 "getTokenPriceUSD(address)" 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd --rpc-url bsc_testnet
	@echo "USDC Native Price:"
	@cast call 0xb512457fcB3020dC4a62480925B68dc83E776340 "getTokenPriceNative(address)" 0x64544969ed7EBf5f083679233325356EbE738930 --rpc-url bsc_testnet
