// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.7;

contract MockChainlinkOracle {

    int256  public price;
    uint256 public updatedAt;

    function latestRoundData() external view returns (
        uint80  roundId_,
        int256  price_,
        uint256 startedAt_,
        uint256 updatedAt_,
        uint80  answeredInRound_
    ) {
        roundId_;
        answeredInRound_;  // to silence the compiler warning

        price_           = price;
        startedAt_       = 0;
        updatedAt_       = updatedAt;
    }

    function __setPrice(int256 price_) external {
        price = price_;
    }

    function __setUpdatedAt(uint256 updatedAt_) external {
        updatedAt = updatedAt_;
    }

}

contract MockPoolManager {

    address public factory;
    address public poolDelegate;

    constructor(address poolDelegate_) {
        poolDelegate = poolDelegate_;
    }

    function setActive(bool active_) external { }

    function __setFactory(address factory_) external {
        factory = factory_;
    }

}

contract MockProxyFactory {

    bool _isInstance;

    function isInstance(address instance_) external view returns (bool isInstance_) {
        instance_;
        isInstance_ = _isInstance;
    }

    function __setIsInstance(bool isInstance_) external {
        _isInstance = isInstance_;
    }

}
