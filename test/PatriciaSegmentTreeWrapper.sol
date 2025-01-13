// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.24;

import "../src/PatriciaSegmentTree.sol";

contract PatriciaSegmentTreeWrapper {
    using PatriciaSegmentTreeLib for PatriciaSegmentTreeLib.PatriciaSegmentTree;

    PatriciaSegmentTreeLib.PatriciaSegmentTree internal tree;

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

    function findParent(uint256 a, uint256 b, uint8 offset)
        external
        pure
        returns (PatriciaSegmentTreeLib.Data memory)
    {
        return PatriciaSegmentTreeLib.findParent(a, b, offset);
    }

    function loadRootNode() external view returns (uint256) {
        return PatriciaSegmentTreeLib.encodeData(tree.loadRootNode().data);
    }

    function loadNode(PatriciaSegmentTreeLib.Data calldata data) external view returns (uint256) {
        return PatriciaSegmentTreeLib.encodeData(tree.loadNode(data).data);
    }

    function loadChildrenMap(PatriciaSegmentTreeLib.Data calldata data) external view returns (uint256) {
        return tree.loadChildrenMap(data);
    }
}
