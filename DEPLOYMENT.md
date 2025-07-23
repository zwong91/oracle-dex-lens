# OracleDexLens 部署指南

## 概述

OracleDexLens 是一个去中心化价格预言机，支持从多个 DEX 版本和 Chainlink 获取代币价格。

## 支持的网络

- **BSC Testnet** (Chain ID: 97)
- **BSC Mainnet** (Chain ID: 56)

## 部署命令

### 测试网部署

```bash
make deploy-testnet
# 或者
make deploy-chapel
```

### 主网部署

```bash
make deploy-mainnet
```

### 查看部署信息

```bash
make info
```

## 环境配置

确保你的 `.env` 文件包含以下变量：

```env
PRIVATE_KEY=你的私钥
ETHERSCAN_API_KEY=你的etherscan_api_key
BSC_RPC_URL=可选的BSC_RPC_URL（如果不设置会使用默认值）
```

## 网络配置

网络配置存储在 `script/config/deployments.json` 中：

### BSC Testnet 配置

- Factory V2.2: `0x7D73A6eFB91C89502331b2137c2803408838218b`
- WBNB: `0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd`
- Chainlink BNB/USD: `0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526`

### BSC Mainnet 配置

- Factory V2.2: `0x55268e26DA30fEAc50B26511ba70C5Cac2Af43B8`
- Factory V2.1: `0x5d0FDDbe7d4c2424F74E276db749E23206b925B9`
- WBNB: `0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c`
- Chainlink BNB/USD: `0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE`

## 部署脚本工作原理

部署脚本 (`script/deploy.s.sol`) 会：

1. 根据 `TARGET_NETWORK` 环境变量选择网络配置
2. 部署 `OracleDexLens` 实现合约
3. 部署 `ProxyAdmin` 管理合约
4. 部署 `TransparentUpgradeableProxy` 代理合约
5. 使用 Chainlink BNB/USD 数据源初始化合约

## 测试和验证

### 运行测试

```bash
make test
```

### 测试部署配置

```bash
make test-deploy
```

### 调用合约进行测试

```bash
make call-OracleDexLens
```

## 添加数据源

### 主网

```bash
make add-datafeeds
```

### 测试网

```bash
make add-datafeeds-testnet
```

## 其他有用命令

```bash
make build          # 编译合约
make clean           # 清理编译文件
make debug-contract  # 调试合约
make test-chainlink  # 测试 Chainlink 集成
```
