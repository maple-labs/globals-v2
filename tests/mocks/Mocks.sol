// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.7;

contract MockChainlinkOracle {

    uint80  public answeredInRound;
    int256  public price;
    uint80  public roundId;
    uint256 public updatedAt;

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

}

contract MockPoolManager {

    address public poolDelegate;

    constructor(address poolDelegate_) {
        poolDelegate = poolDelegate_;
    }

    function setActive(bool active_) external { }

}
