# DexLens Oracle 修复部署指南

## 问题诊断

- 当前 USDC 价格被 Oracle 返回为 $686 (应该是 ~$1)
- 原因：DexLens 合约没有为 USDC 配置 Chainlink 数据源
- 结果：你的 0.1 USDC 被计算为价值 68.6 USD

## 修复步骤

### 1. 配置环境变量

```bash
cd /Users/enty/dex/backend/oracle-dex-lens
cp .env.example .env
# 编辑 .env 文件，设置你的私钥
```

### 2. 部署数据源配置

```bash
# 添加 USDC 和 USDT 的正确 Chainlink 数据源
forge script script/add-datafeeds.s.sol \
  --fork-url https://data-seed-prebsc-1-s1.bnbchain.org:8545 \
  --broadcast \
  --verify
```

### 3. 验证修复

```bash
# 测试修复后的价格
forge script script/test-current-prices.s.sol \
  --fork-url https://data-seed-prebsc-1-s1.bnbchain.org:8545
```

## 配置详情

**DexLens 合约地址**: `0x8C7dc8184F5D78Aa40430b2d37f78fDC3e9A9b78`

**添加的数据源**:

- USDC: `0x64544969ed7EBf5f083679233325356EbE738930`

  - Chainlink Feed: `0x90c069C4538adAc136E051052E14c1cD799C41B7` (USDC/USD)
  - 正确价格: ~$1.00

- USDT: `0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684`
  - Chainlink Feed: `0xEca2605f0BCF2BA5966372C99837b1F182d3D620` (USDT/USD)
  - 正确价格: ~$1.00

## 预期结果

修复后：

- USDC 价格将正确显示为 ~$1.00
- 你的 0.1 USDC 将正确计算为 ~$0.10 价值
- TVL 计算将恢复正常

## 备用方案

如果网络问题无法部署，可以：

1. 使用 BSC 测试网浏览器直接调用合约
2. 或重新部署一个新的 DexLens 合约
3. 或在 indexer 中保持价格校正逻辑
