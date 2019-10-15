pragma solidity ^0.5.10;

import {SafeMath} from "@summa-tx/bitcoin-spv-sol/contracts/SafeMath.sol";
import "../interfaces/IPriceOracle.sol";

/// @title BTC-ETH Price Oracle V1
/// @notice Implements a simple price feed, managed by a trusted operator.
contract PriceOracleV1 is IPriceOracle {
    using SafeMath for uint128;

    // Price of BTC expressed in ETH, denominated in `x` wei to a satoshi.
    //
    // A bitcoin has 8 decimal places, the smallest unit a satoshi,
    // meaning 100 000 000 sat = 1 bitcoin
    //
    // An ether by contract, has 18 decimal places, the smallest unit a wei,
    // meaning 1 000 000 000 000 000 000 wei = 1 ether
    //
    // eg. 1 BTC : 32.32 ETH (Jun 2019), which represents:
    //     100 000 000 sat : 32 320 000 000 000 000 000 wei
    //               1 sat : 323 200 000 000 wei
    //               price = 323200000000
    //
    // uint128 can store an int of max size 2^128 (3.403 e38)
    // 38 decimals should be enough to store the price of a satoshi in wei
    uint128 internal price;

    // The time at which the last price update is not valid for usage.
    uint256 public priceExpiryTime;
    uint256 constant PRICE_EXPIRY_PERIOD = 6 hours;
    uint256 constant PRICE_NEAR_EXPIRY_PERIOD = 1 hours;

    // Trusted user that updates the oracle.
    address public operator;

    constructor(
        address _operator,
        uint128 _defaultPrice
    ) public {
        operator = _operator;
        price = _defaultPrice;
        priceExpiryTime = block.timestamp + PRICE_EXPIRY_PERIOD;
    }

    function getPrice() external view returns (uint128) {
        require(block.timestamp < priceExpiryTime, "Price expired");
        return price;
    }

    /// @notice Updates the price
    /// @dev Requires price to differ by at least 1%, unless it is close to expiry
    function updatePrice(uint128 _newPrice) external {
        require(msg.sender == operator, "Unauthorised");

        bool nearExpiry = (priceExpiryTime - PRICE_NEAR_EXPIRY_PERIOD) <= block.timestamp;

        if(!nearExpiry) {
            // abs(1 - (p1 / p0)) > 0.01
            // p0 * 0.01 = minimum delta
            // 1% = 0.01 = 1/100
            uint256 minDelta = price.div(100);
            /* solium-disable */
            uint256 delta = _newPrice > price
                            ? _newPrice.sub(price)
                            : price.sub(_newPrice);
            /* solium-enable */
            require(delta >= minDelta, "Price change is negligible (<1%)");
        }

        price = _newPrice;
        priceExpiryTime = block.timestamp + PRICE_EXPIRY_PERIOD;

        emit PriceUpdated(price, priceExpiryTime);
    }
}
