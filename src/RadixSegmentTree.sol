// SPDX-License-Identifier: AGPL-3.0-only

pragma solidity >=0.8.0;

library RadixSegmentTreeLib {
    // bytes32(uint256(keccak256("RadixSegmentTree")) - 1)
    uint256 internal constant ROOT = 0x93d586536338c237314802209ad99ffc16300a0123983a9edf87427344edd372;
    uint256 internal constant MAX_VALUE = 2**239 - 1;

    struct RadixSegmentTree {
        mapping(bytes32 entry => uint256) branch;
    }

    struct Node {
        bool isLeaf;
        uint16 children;
        uint256 entry; // @dev entry < 2**239
    }

    function add(RadixSegmentTree storage tree, uint256 value) internal {}

    function remove(RadixSegmentTree storage tree, uint256 value) internal {}

    function update(RadixSegmentTree storage tree, uint256 from, uint256 to) internal {}

    function query(RadixSegmentTree storage tree, uint256 value) internal view returns (uint256 left, uint256 mid, uint256 right) {}

    function _getNode(uint256 slot) internal view returns (Node memory node) {
        assembly {
            let data := sload(slot)
            mstore(node, and(data, 1))
            mstore(add(node, 0x20), and(shr(1, data), 0xffff))
            mstore(add(node, 0x40), shr(17, data))
        }
    }
}
