# Chainlink USD Stablecoin 配置说明

## 问题分析

对于 Chainlink USD 数据源（如 USDC/USD, USDT/USD），我们需要将 USD 价格转换为相对于 WBNB 的价格。

### 当前系统的转换逻辑

```solidity
if (dataFeed.collateralAddress != _WNATIVE) {
    uint256 collateralPrice = _getTokenWeightedAverageNativePrice(dataFeed.collateralAddress);
    dfPrice = dfPrice * collateralPrice / _WNATIVE_PRECISION;
}
```

### 我们需要的转换

```
USDC_相对于WBNB = USDC_USD / WBNB_USD
```

### 系统实际计算

```
USDC_相对于WBNB = USDC_USD * collateralPrice / 1e18
```

### 解决方案

我们需要：`collateralPrice = 1e18 / WBNB_USD`

## 实现方案

### 1. 创建反向 WBNB 聚合器

`InverseWBNBAggregator.sol` 合约返回 `1e36 / WBNB_USD_price`

### 2. 部署反向聚合器

```bash
make deploy-inverse-aggregator
```

### 3. 更新数据源脚本

将部署的反向聚合器地址更新到 `add-datafeeds.s.sol` 中的 `INVERSE_WBNB_AGGREGATOR` 常量。

### 4. 配置数据源

```bash
make add-datafeeds-testnet
```

## 配置逻辑

1. **反向 WBNB 代币**:
   - Token: `INVERSE_WBNB_TOKEN` (虚拟地址)
   - Aggregator: `InverseWBNBAggregator`
   - CollateralAddress: 自己
   - 价格: `1e18 / WBNB_USD`

2. **USDC 稳定币**:
   - Token: `USDC`
   - Aggregator: `USDC_USD_AGGREGATOR`
   - CollateralAddress: `INVERSE_WBNB_TOKEN`
   - 计算: `USDC_USD * (1e18/WBNB_USD) / 1e18 = USDC_USD / WBNB_USD`

3. **USDT 稳定币**: 同 USDC

## 预期结果

- **USDC Native 价格**: `~0.00126` (1 USD / 793 USD ≈ 0.00126)
- **USDC USD 价格**: `~1.00 USD`
- **USDT Native 价格**: `~0.00126`
- **USDT USD 价格**: `~1.00 USD`

## 部署步骤

1. 部署反向聚合器:

   ```bash
   make deploy-inverse-aggregator
   ```

2. 复制输出的合约地址，更新 `script/add-datafeeds.s.sol` 中的 `INVERSE_WBNB_AGGREGATOR`

3. 添加数据源:

   ```bash
   make add-datafeeds-testnet
   ```

4. 测试价格:

   ```bash
   make call-dexlens
   ```
