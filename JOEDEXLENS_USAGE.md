# JoeDexLens 合约使用指南

## 部署信息

### BSC 测试网 
- **主合约地址 (代理)**: `0x8C7dc8184F5D78Aa40430b2d37f78fDC3e9A9b78`
- **实现合约地址**: `0x6a2a650C4646324F30f0D09bF5DC546c39F5D368`
- **ProxyAdmin地址**: `0xbB6D6810a6eFE2519Bd7a2C917F9BE5B2CF82EBd`
- **网络**: BSC Testnet (Chain ID: 97)
- **价格数据源**: Chainlink BNB/USD (`0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526`)

## 主要功能

### 1. 价格查询功能

#### 获取代币相对于原生代币(BNB)的价格
```bash
cast call 0x8C7dc8184F5D78Aa40430b2d37f78fDC3e9A9b78 "getTokenPriceNative(address)" <TOKEN_ADDRESS> --rpc-url bsc_testnet
```

#### 获取代币的USD价格 - WBNB价格约$662.68 USD（实时市场价格）
```bash
cast call 0x8C7dc8184F5D78Aa40430b2d37f78fDC3e9A9b78 "getTokenPriceUSD(address)" <TOKEN_ADDRESS> --rpc-url bsc_testnet
```

#### 批量获取代币的原生价格 - WBNB价格返回1.0（符合预期）
```bash
cast call 0x8C7dc8184F5D78Aa40430b2d37f78fDC3e9A9b78 "getTokensPricesNative(address[])" "[TOKEN1,TOKEN2,...]" --rpc-url bsc_testnet
```

#### 批量获取代币的USD价格
```bash
cast call 0x8C7dc8184F5D78Aa40430b2d37f78fDC3e9A9b78 "getTokensPricesUSD(address[])" "[TOKEN1,TOKEN2,...]" --rpc-url bsc_testnet
```

### 2. 合约信息查询

#### 获取包装原生代币地址- 返回正确的WBNB地址
```bash
cast call 0x8C7dc8184F5D78Aa40430b2d37f78fDC3e9A9b78 "getWNative()" --rpc-url bsc_testnet
```

#### 获取代币的数据源信息
```bash
cast call 0x8C7dc8184F5D78Aa40430b2d37f78fDC3e9A9b78 "getDataFeeds(address)" <TOKEN_ADDRESS> --rpc-url bsc_testnet
```

## 测试结果

### WBNB 价格测试
```bash
# Native(WBNB)价格 (返回1.0（符合预期）)
$ cast call 0x8C7dc8184F5D78Aa40430b2d37f78fDC3e9A9b78 "getTokenPriceNative(address)" 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd --rpc-url bsc_testnet
返回: 1000000000000000000 (= 1.0 in 18 decimals)

# WBNB USD价格
$ cast call 0x8C7dc8184F5D78Aa40430b2d37f78fDC3e9A9b78 "getTokenPriceUSD(address)" 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd --rpc-url bsc_testnet
返回: 662675099090000000000 (= $662.68 USD)
```

### WNative地址查询
```bash
$ cast call 0x8C7dc8184F5D78Aa40430b2d37f78fDC3e9A9b78 "getWNative()" --rpc-url bsc_testnet
返回: 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd (BSC测试网WBNB地址)
```

## 快速使用脚本

我们提供了一个便捷的脚本 `call-joedexlens.sh`，可以快速测试所有功能：

```bash
# 运行测试脚本
./call-joedexlens.sh
```

## 价格数据格式

所有价格都以18位小数返回（wei格式）：
- 返回值 `1000000000000000000` = 1.0
- 要转换为可读格式：`price_in_wei / 10^18`

### 转换示例
```bash
# 使用 bc 计算器转换
echo "scale=6; 662675099090000000000 / 1000000000000000000" | bc
# 输出: 662.675099
```

## BSC测试网代币地址

```javascript
WBNB  = "0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd"
BUSD  = "0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7" 
USDT  = "0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684"
```

## 工作原理

1. **原生价格查询**: 直接返回代币相对于WBNB的价格
2. **USD价格查询**: 
   - 先获取代币相对于WBNB的价格
   - 通过Chainlink BNB/USD价格源获取BNB的USD价格
   - 计算最终的USD价格
3. **数据来源**: 
   - 使用Trader Joe的多个版本DEX (V1, V2, V2.1, V2.2)
   - 回退到Chainlink价格源
   - 支持自定义数据源配置

## 错误处理

- 如果代币没有流动性池或数据源，价格查询可能返回 `0`
- 某些测试网代币可能没有足够的流动性，导致价格查询失败
- USD价格依赖于BNB/USD价格源的可用性

## 智能合约接口

完整的接口定义可参考 `src/interfaces/IJoeDexLens.sol`

### 主要函数签名
```solidity
function getWNative() external view returns (address);
function getTokenPriceNative(address token) external view returns (uint256);
function getTokenPriceUSD(address token) external view returns (uint256);
function getTokensPricesNative(address[] calldata tokens) external view returns (uint256[] memory);
function getTokensPricesUSD(address[] calldata tokens) external view returns (uint256[] memory);
function getDataFeeds(address token) external view returns (DataFeed[] memory);
```

## 注意事项

⚠️ **重要**: 此合约仅用于分析和统计目的，不应用于任何金融操作的价格预言机！

✅ **成功部署**: 合约已成功部署到BSC测试网，所有基本功能都已验证可用

🔍 **价格验证**: WBNB价格查询返回正确的USD价格（约$662.68），表明Chainlink价格源工作正常
