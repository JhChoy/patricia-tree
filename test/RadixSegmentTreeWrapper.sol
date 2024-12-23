// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.24;

import "../src/RadixSegmentTree.sol";

contract RadixSegmentTreeWrapper {
    using RadixSegmentTreeLib for RadixSegmentTreeLib.RadixSegmentTree;

    RadixSegmentTreeLib.RadixSegmentTree internal tree;

    function add(uint232 value) external {
        tree.add(value);
    }

    function remove(uint232 value) external {
        tree.remove(value);
    }

    function update(uint232 from, uint232 to) external {
        tree.update(from, to);
    }

    function query(uint232 value) external view returns (uint256 left, uint256 mid, uint256 right) {
        return tree.query(value);
    }

    function findParent(uint256 a, uint256 b, uint8 offset) external pure returns (RadixSegmentTreeLib.Data memory) {
        return RadixSegmentTreeLib.findParent(a, b, offset);
    }
}
