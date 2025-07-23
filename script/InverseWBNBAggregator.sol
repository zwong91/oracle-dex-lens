// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../src/interfaces/AggregatorV3Interface.sol";

/**
 * @title InverseWBNBAggregator
 * @dev A custom aggregator that returns 1e18 / WBNB_USD_price
 * This is used to create the correct collateral price for USD stablecoins
 */
contract InverseWBNBAggregator is AggregatorV3Interface {
    AggregatorV3Interface public immutable bnbUsdAggregator;
    uint8 public constant override decimals = 18;
    string public constant description = "Inverse WBNB / USD";
    uint256 public constant override version = 1;

    constructor(address _bnbUsdAggregator) {
        require(_bnbUsdAggregator != address(0), "Invalid aggregator address");
        bnbUsdAggregator = AggregatorV3Interface(_bnbUsdAggregator);
    }

    /**
     * @dev Returns the inverse of BNB/USD price
     * If BNB/USD = 600, this returns 1e36 / 600e18 = 1.667e15 (with 18 decimals)
     */
    function latestRoundData()
        external
        view
        override
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        )
    {
        (uint80 _roundId, int256 bnbUsdPrice, uint256 _startedAt, uint256 _updatedAt, uint80 _answeredInRound) = 
            bnbUsdAggregator.latestRoundData();
        
        require(bnbUsdPrice > 0, "Invalid BNB price");
        
        // Convert BNB/USD price to have 18 decimals
        uint8 bnbDecimals = bnbUsdAggregator.decimals();
        uint256 bnbUsdPriceWith18Decimals;
        
        if (bnbDecimals <= 18) {
            bnbUsdPriceWith18Decimals = uint256(bnbUsdPrice) * 10**(18 - bnbDecimals);
        } else {
            bnbUsdPriceWith18Decimals = uint256(bnbUsdPrice) / 10**(bnbDecimals - 18);
        }
        
        // Calculate inverse: 1e36 / bnbUsdPrice
        // This gives us the price in terms of "1/USD per WBNB"
        // Add safety check to prevent division by zero
        require(bnbUsdPriceWith18Decimals > 0, "Invalid converted BNB price");
        
        uint256 inversePrice = 1e36 / bnbUsdPriceWith18Decimals;
        require(inversePrice <= uint256(type(int256).max), "Overflow in inverse calculation");
        
        return (_roundId, int256(inversePrice), _startedAt, _updatedAt, _answeredInRound);
    }

    function getRoundData(uint80 _roundId)
        external
        view
        override
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        )
    {
        return bnbUsdAggregator.getRoundData(_roundId);
    }
}
