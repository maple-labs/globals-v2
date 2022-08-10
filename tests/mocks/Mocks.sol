// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.7;

contract MockChainlinkOracle {

    uint80  answeredInRound;
    int256  price;
    uint80  roundId;
    uint256 updatedAt;

    function __setAnsweredInRound(uint80 answeredInRound_) external {
        answeredInRound = answeredInRound_;
    }

    function __setPrice(int256 price_) external {
        price = price_;
    }

    function __setRoundId(uint80 roundId_) external {
        roundId = roundId_;
    }

    function __setUpdatedAt(uint256 updatedAt_) external {
        updatedAt = updatedAt_;
    }

    function latestRoundData() external view returns (
        uint80  roundId_,
        int256  price_,
        uint256 startedAt_,
        uint256 updatedAt_,
        uint80  answeredInRound_
    ) {
        roundId_         = roundId;
        price_           = price;
        startedAt_       = 0;
        updatedAt_       = updatedAt;
        answeredInRound_ = answeredInRound;
    }

}

contract MockPoolManager {

    address public poolDelegate;

    constructor(address poolDelegate_) {
        poolDelegate = poolDelegate_;
    }

    function setActive(bool active_) external { }

}
