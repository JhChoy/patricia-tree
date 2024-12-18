// SPDX-License-Identifier: AGPL-3.0-only

pragma solidity >=0.8.0;

/// @notice Radix-Segment Tree implementation.
/// @author JChoy (https://github.com/JhChoy/radix-segment-tree/blob/master/src/RadixSegmentTree.sol)
library RadixSegmentTreeLib {
    // bytes32(uint256(keccak256("RadixSegmentTree")) - 1)
    uint256 internal constant ROOT = 0x93d586536338c237314802209ad99ffc16300a0123983a9edf87427344edd372;
    uint256 internal constant MAX_VALUE = 2 ** 239 - 1;

    struct RadixSegmentTree {
        mapping(bytes32 entry => uint256) branch;
    }

    struct Node {
        uint16 children;
        uint8 length; // @dev length < 2**4
        uint256 entry; // @dev entry < 2**236
    }

    function add(RadixSegmentTree storage tree, uint256 value) internal {}

    function remove(RadixSegmentTree storage tree, uint256 value) internal {}

    function update(RadixSegmentTree storage tree, uint256 from, uint256 to) internal {}

    function query(RadixSegmentTree storage tree, uint256 value)
        internal
        view
        returns (uint256 left, uint256 mid, uint256 right)
    {}

    function _slot(RadixSegmentTree storage tree, uint256 entry) private pure returns (bytes32 slot) {
        assembly {
            slot := tree.slot
        }
        slot = keccak256(abi.encodePacked(ROOT, slot, entry));
    }

    function _getRootNode(RadixSegmentTree storage tree) private view returns (Node memory) {
        bytes32 slot;
        assembly {
            slot := tree.slot
        }
        return _getNode(slot);
    }

    function _getNode(bytes32 slot) private view returns (Node memory node) {
        assembly {
            let data := sload(slot)
            mstore(node, and(data, 0xffff))
            mstore(add(node, 0x20), and(shr(16, data), 0xf))
            mstore(add(node, 0x40), shr(20, data))
        }
    }
}
