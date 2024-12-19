// SPDX-License-Identifier: AGPL-3.0-only

pragma solidity >=0.8.0;

/// @notice Radix-Segment Tree implementation.
/// @author JChoy (https://github.com/JhChoy/radix-segment-tree/blob/master/src/RadixSegmentTree.sol)
library RadixSegmentTreeLib {
    error WrongOffset();

    // bytes32(uint256(keccak256("RadixSegmentTree")) - 1)
    uint256 internal constant ROOT = 0x93d586536338c237314802209ad99ffc16300a0123983a9edf87427344edd372;
    uint256 internal constant MAX_VALUE = 2 ** 232 - 1;

    struct RadixSegmentTree {
        mapping(bytes32 entry => uint256) branch;
    }

    struct Node {
        uint16 children;
        uint8 length; // @dev length < 2**4
        uint232 entry;
    }

    function add(RadixSegmentTree storage tree, uint232 value) internal {
    }

    function remove(RadixSegmentTree storage tree, uint232 value) internal {}

    function update(RadixSegmentTree storage tree, uint232 from, uint232 to) internal {}

    function query(RadixSegmentTree storage tree, uint232 value)
        internal
        view
        returns (uint256 left, uint256 mid, uint256 right)
    {}

    function findBranch(uint256 a, uint256 b, uint8 offset) internal pure returns (uint256 r, uint8 length) {
        require(a != b && offset < 64);
        assembly {
            // a = 0x132xx...x
            // b = 0x134xx...x
            // c = 0xffxxx...x
            let c := not(xor(a, b))
            // Generate `offset` number of 0x`f`s at the front.
            offset := sub(64, offset)
            let lastMask := not(sub(shl(shl(2, offset), 1), 1)) // ~((1 << (offset << 2)) - 1)
            if lt(c, lastMask) {
                mstore(0x00, 0xea08b33a) // `WrongOffset()`.
                revert(0x1c, 0x04)
            }
            for {} true {} {
                offset := sub(offset, 1)
                // Append 0xf to the last mask
                // lastMask + (0xf << (offset << 2))
                let mask := add(lastMask, shl(shl(2, offset), 0xf))
                // If c < mask, then a and b have different hex digits.
                // 0xffffxxx...xx < 0xfffff00...00
                if lt(c, mask) {
                    r := and(a, lastMask)
                    // Find the length of the common prefix.
                    // `offset` cannot be 64, because a != b.
                    length := sub(63, offset)
                    break
                }
                lastMask := mask
            }
        }
        // Sanity check
        require(r <= a && r <= b);
    }

    function _slot(RadixSegmentTree storage tree, uint232 entry) private pure returns (bytes32 slot) {
        assembly {
            slot := tree.slot
        }
        slot = keccak256(abi.encodePacked(ROOT, slot, entry));
    }

    function _loadRootNode(RadixSegmentTree storage tree) private view returns (Node memory) {
        bytes32 slot;
        assembly {
            slot := tree.slot
        }
        return _loadNode(slot);
    }

    function _loadNode(bytes32 slot) private view returns (Node memory node) {
        assembly {
            let data := sload(slot)
            mstore(node, and(data, 0xffff))
            mstore(add(node, 0x20), and(shr(16, data), 0xf))
            mstore(add(node, 0x40), shr(24, data))
        }
    }

    function _storeNode(bytes32 slot, Node memory node) private {
        assembly {
            let data := mload(node)
            data := add(data, shl(16, mload(add(node, 0x20))))
            data := add(data, shl(24, mload(add(node, 0x40))))
            sstore(slot, data)
        }
    }
}
