// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import {IJoeFactory} from "lb-dlmm/interfaces/IJoeFactory.sol";
import {ILBFactory} from "lb-dlmm/interfaces/ILBFactory.sol";
import {ILBLegacyFactory} from "lb-dlmm/interfaces/ILBLegacyFactory.sol";
import {ISafeAccessControlEnumerable} from "solrary/access/ISafeAccessControlEnumerable.sol";

import {AggregatorV3Interface} from "../interfaces/AggregatorV3Interface.sol";

/// @title Interface of the Joe Dex Lens contract
/// @author Trader Joe
/// @notice The interface needed to interract with the Joe Dex Lens contract
interface IJoeDexLens is ISafeAccessControlEnumerable {
    error JoeDexLens__UnknownDataFeedType();
    error JoeDexLens__CollateralNotInPair(address pair, address collateral);
    error JoeDexLens__TokenNotInPair(address pair, address token);
    error JoeDexLens__SameTokens();
    error JoeDexLens__DataFeedAlreadyAdded(address token, address dataFeed);
    error JoeDexLens__DataFeedNotInSet(address token, address dataFeed);
    error JoeDexLens__LengthsMismatch();
    error JoeDexLens__NullWeight();
    error JoeDexLens__InvalidChainLinkPrice();
    error JoeDexLens__V1ContractNotSet();
    error JoeDexLens__V2ContractNotSet();
    error JoeDexLens__V2_1ContractNotSet();
    error JoeDexLens__V2_2ContractNotSet();
    error JoeDexLens__AlreadyInitialized();
    error JoeDexLens__InvalidDataFeed();
    error JoeDexLens__ZeroAddress();
    error JoeDexLens__EmptyDataFeeds();
    error JoeDexLens__SameDataFeed();
    error JoeDexLens__ExceedsMaxLevels();
    error JoeDexLens__InvalidLevel();
    error JoeDexLens__NoDataFeeds(address token);
    error JoeDexLens__ExceedsMaxTokensPerLevel();

    /// @notice Enumerators of the different data feed types
    enum DataFeedType {
        V1,
        V2,
        V2_1,
        CHAINLINK,
        V2_2
    }

    /**
     * @notice Structure for data feeds, contains the data feed's address and its type.
     * For V1/V2, the`dfAddress` should be the address of the pair
     * For chainlink, the `dfAddress` should be the address of the aggregator
     */
    struct DataFeed {
        address collateralAddress;
        address dfAddress;
        uint88 dfWeight;
        DataFeedType dfType;
    }

    /**
     * @notice Structure for a set of data feeds
     * `datafeeds` is the list of all the data feeds
     * `indexes` is a mapping linking the address of a data feed to its index in the `datafeeds` list.
     */
    struct DataFeedSet {
        DataFeed[] dataFeeds;
        mapping(address => uint256) indexes;
    }

    /**
     * @notice List of trusted tokens
     */
    struct TrustedTokens {
        address[] tokens;
    }

    event DataFeedAdded(address token, DataFeed dataFeed);

    event DataFeedsWeightSet(address token, address dfAddress, uint256 weight);

    event DataFeedRemoved(address token, address dfAddress);

    event TrustedTokensSet(uint256 indexed level, address[] tokens);

    function getWNative() external view returns (address wNative);

    function getFactoryV1() external view returns (IJoeFactory factoryV1);

    function getLegacyFactoryV2() external view returns (ILBLegacyFactory legacyFactoryV2);

    function getFactoryV2_1() external view returns (ILBFactory factoryV2);

    function getFactoryV2_2() external view returns (ILBFactory factoryV2_2);

    function getDataFeeds(address token) external view returns (DataFeed[] memory dataFeeds);

    function getTokenPriceUSD(address token) external view returns (uint256 price);

    function getTokenPriceNative(address token) external view returns (uint256 price);

    function getTokensPricesUSD(address[] calldata tokens) external view returns (uint256[] memory prices);

    function getTokensPricesNative(address[] calldata tokens) external view returns (uint256[] memory prices);

    function addDataFeed(address token, DataFeed calldata dataFeed) external;

    function setDataFeedWeight(address token, address dfAddress, uint88 newWeight) external;

    function removeDataFeed(address token, address dfAddress) external;

    function setTrustedTokensAt(uint256 level, address[] calldata tokens) external;

    function addDataFeeds(address[] calldata tokens, DataFeed[] calldata dataFeeds) external;

    function setDataFeedsWeights(
        address[] calldata _tokens,
        address[] calldata _dfAddresses,
        uint88[] calldata _newWeights
    ) external;

    function removeDataFeeds(address[] calldata tokens, address[] calldata dfAddresses) external;
}
