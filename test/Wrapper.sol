// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.24;

import "../src/RadixSegmentTree.sol";

contract RadixSegmentTreeWrapper {
    using RadixSegmentTreeLib for RadixSegmentTreeLib.RadixSegmentTree;

    RadixSegmentTreeLib.RadixSegmentTree internal tree;

    function add(uint256 value) external {
        tree.add(value);
    }

    function remove(uint256 value) external {
        tree.remove(value);
    }

    function update(uint256 from, uint256 to) external {
        tree.update(from, to);
    }

    function query(uint256 value) external view returns (uint256 left, uint256 mid, uint256 right) {
        return tree.query(value);
    }
}
