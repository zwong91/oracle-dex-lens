es@192 oracle-dex-lens % source .env && forge script script/deploy.s.sol:Deploy --rpc-url bsc_testnet --broadcast
[⠊] Compiling...
[⠆] Compiling 53 files with Solc 0.8.20
[⠰] Solc 0.8.20 finished in 16.73s
Compiler run successful!

Script ran successfully.

== Return ==
0: contract JoeDexLens[] [0x6a2a650C4646324F30f0D09bF5DC546c39F5D368]
1: contract ProxyAdmin[] [0xbB6D6810a6eFE2519Bd7a2C917F9BE5B2CF82EBd]
2: contract TransparentUpgradeableProxy[] [0x8C7dc8184F5D78Aa40430b2d37f78fDC3e9A9b78]

== Logs ==
  
Deploying Dex Lens on bnb_smart_chain_testnet

## Setting up 1 EVM.

==========================

Chain 97

Estimated gas price: 0.1 gwei

Estimated total gas used for script: 7021115

Estimated amount required: 0.0007021115 BNB

==========================

##### bsc-testnet
✅  [Success] Hash: 0x8d2262e497635205fb154533b99789ac62892f983299540d2b32ecefabdbf056
Contract Address: 0x6a2a650C4646324F30f0D09bF5DC546c39F5D368
Block: 56006744
Paid: 0.0004274932 ETH (4274932 gas * 0.1 gwei)


##### bsc-testnet
✅  [Success] Hash: 0x859a30d6b5ec1a0533a07c1a6b5e920f229ce5aa6eacee07b290cabd27c816fa
Contract Address: 0xbB6D6810a6eFE2519Bd7a2C917F9BE5B2CF82EBd
Block: 56006742
Paid: 0.0000290012 ETH (290012 gas * 0.1 gwei)


##### bsc-testnet
✅  [Success] Hash: 0x308192af4083a3dbd594ecfb3f2e279250dc30ba55a28cef2c0547763d695e70
Contract Address: 0x8C7dc8184F5D78Aa40430b2d37f78fDC3e9A9b78
Block: 56006744
Paid: 0.0000835915 ETH (835915 gas * 0.1 gwei)

✅ Sequence #1 on bsc-testnet | Total Paid: 0.0005400859 ETH (5400859 gas * avg 0.1 gwei)
                                                                                                                         

==========================

ONCHAIN EXECUTION COMPLETE & SUCCESSFUL.

Transactions saved to: /Users/es/oracle-dex-lens/broadcast/deploy.s.sol/97/run-latest.json

Sensitive values saved to: /Users/es/oracle-dex-lens/cache/deploy.s.sol/97/run-latest.json


## 部署成功！✅

通过启用Solidity优化器，我们解决了合约大小问题并完成了部署：

### 已部署的合约地址：

1. **JoeDexLens Implementation**: `0x6a2a650C4646324F30f0D09bF5DC546c39F5D368`
2. **ProxyAdmin**: `0xbB6D6810a6eFE2519Bd7a2C917F9BE5B2CF82EBd` 
3. **TransparentUpgradeableProxy** (主合约地址): `0x8C7dc8184F5D78Aa40430b2d37f78fDC3e9A9b78`

### 关键改进：

1. **启用了Solidity优化器**：
   - `optimizer = true`
   - `optimizer_runs = 200`
   - `via_ir = true`

2. **使用了正确的价格数据源**：
   - BSC测试网的BNB/USD Chainlink价格数据源：`0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526`

3. **部署费用**：
   - 总计：0.0005400859 BNB
   - 约等于：0.0005400859 ETH (在BSC测试网上)

### 使用方法：

现在您可以使用主合约地址 `0x8C7dc8184F5D78Aa40430b2d37f78fDC3e9A9b78` 来调用JoeDexLens的功能：

- `getTokenPriceNative()` - 获取代币相对于BNB的价格
- `getTokensPricesNative()` - 批量获取多个代币的BNB价格
- `getTokenPriceUSD()` - 获取代币的USD价格（通过BNB/USD价格数据源）