# BSC Mainnet Deployment Guide

## Overview

This document describes the deployment process for OracleDexLens on BSC Mainnet.

## Deployed Contracts

### BSC Mainnet (Chain ID: 56)

- **InverseWBNBAggregator**: `0xA89fe2F67d78F26F077E2811b2948399A4e5aF0A`
  - Transaction: `0xbdfa8aeff1831e2c3be5baca0992d2f5611dd2eb94aab64ebf042d985c63468b`
  - Block: 55020597
  - Description: "Inverse WBNB / USD"

### BSC Testnet (Chain ID: 97)

- **InverseWBNBAggregator**: `0x440d1926FF183423EDC84a803f888915A1CDD8df`
  - Status: Verified and working

## Deployment Steps

### 1. Deploy Inverse Aggregator

```bash
# For mainnet
make deploy-inverse-aggregator-mainnet

# For testnet  
make deploy-inverse-aggregator-testnet
```

### 2. Deploy OracleDexLens

```bash
# For mainnet
make deploy-mainnet

# For testnet
make deploy-testnet
```

### 3. Add Data Feeds

```bash
# For mainnet
make add-datafeeds-mainnet

# For testnet
make add-datafeeds-testnet
```

### 4. Verify Data Feeds

```bash
# For mainnet
make verify-datafeeds-mainnet

# For testnet
make verify-datafeeds-testnet
```

## Network Configuration

The unified scripts automatically detect the network based on chain ID:

- Chain ID 56: BSC Mainnet
- Chain ID 97: BSC Testnet

## Data Feed Configuration

### Mainnet Data Feeds

- **BNB/USD**: `0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE` (Chainlink)
- **USDC/USD**: `0x51597f405303C4377E36123cBc172b13269EA163` (Chainlink)
- **USDT/USD**: `0xB97Ad0E74fa7d920791E90258A6E2085088b4320` (Chainlink)
- **Inverse WBNB/USD**: `0xA89fe2F67d78F26F077E2811b2948399A4e5aF0A` (Custom)

### Testnet Data Feeds

- **BNB/USD**: `0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526` (Chainlink)
- **USDC/USD**: `0x90c069C4538adAc136E051052E14c1cD799C41B7` (Chainlink) 
- **USDT/USD**: `0xEca2605f0BCF2BA5966372C99837b1F182d3D620` (Chainlink)
- **Inverse WBNB/USD**: `0x440d1926FF183423EDC84a803f888915A1CDD8df` (Custom)

## Key Features

1. **Unified Scripts**: Same scripts work for both mainnet and testnet
2. **Automatic Network Detection**: Scripts detect network by chain ID
3. **Price Validation**: All data feeds validated during deployment
4. **Overflow Protection**: InverseWBNBAggregator includes safety checks

## Testing

### Test Inverse Aggregator

```bash
# Mainnet
cast call 0xA89fe2F67d78F26F077E2811b2948399A4e5aF0A "latestRoundData()" --rpc-url https://bsc-dataseed.bnbchain.org

# Testnet
cast call 0x440d1926FF183423EDC84a803f888915A1CDD8df "latestRoundData()" --rpc-url bsc_testnet
```

### Expected Results

- Mainnet: Inverse BNB price ~$0.0013 (1/~$775)
- Testnet: Inverse BNB price ~$0.0013 (1/~$793)

## Configuration Files

All network configurations are stored in:

- `script/config/deployments.json`

## Troubleshooting

### Common Issues

1. **Verification Failures**: API key rate limits (contracts still deploy successfully)
2. **Gas Estimation**: Use current BSC gas prices
3. **RPC Issues**: Try alternative BSC RPC endpoints

### Alternative RPC Endpoints

- Mainnet: `https://bsc-dataseed.bnbchain.org`
- Testnet: `https://data-seed-prebsc-1-s1.binance.org:8545`

## Security Notes

1. InverseWBNBAggregator includes overflow protection
2. All aggregators validate price freshness
3. Data feeds use official Chainlink oracles where available
4. Custom aggregators follow Chainlink interface standards
